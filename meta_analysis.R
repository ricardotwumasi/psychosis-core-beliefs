##############
# Meta analysis
###############


# Load required libraries with checks
required_packages <- c("tidyverse", "metafor", "gridExtra", "ggplot2", "dplyr")
lapply(required_packages, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
})

# Read and process the CSV file
process_meta_data <- function() {
  # Read the CSV file
  data <- read.csv("cleaned_meta_analysis151124.csv", stringsAsFactors = FALSE)
  
  # Remove rows with missing effect sizes
  data <- data %>%
    filter(!is.na(fishers_z) & !is.na(fishers_z_se))
  
  # Create factors for grouping variables
  data$combined_clinical_group <- factor(data$combined_clinical_group)
  data$belief_category <- factor(data$belief_category)
  data$study_id <- factor(data$study_id)
  
  # Add year as numeric
  data$year <- as.numeric(data$year)
  
  # Calculate weights (inverse variance weights)
  data$weight <- 1 / (data$fishers_z_se^2)
  
  return(data)
}

# Function to summarize data characteristics
summarize_data <- function(data) {
  # Basic summary
  cat("\nData Summary:\n")
  cat("Number of studies:", length(unique(data$study_id)), "\n")
  cat("Number of effect sizes:", nrow(data), "\n")
  cat("\nClinical Groups:\n")
  print(table(data$combined_clinical_group))
  
  # Effect size summary by clinical group
  summary_stats <- data %>%
    group_by(combined_clinical_group) %>%
    summarize(
      n = n(),
      mean_effect = mean(fishers_z, na.rm = TRUE),
      sd_effect = sd(fishers_z, na.rm = TRUE),
      min_effect = min(fishers_z, na.rm = TRUE),
      max_effect = max(fishers_z, na.rm = TRUE)
    )
  
  cat("\nEffect Size Summary by Clinical Group:\n")
  print(summary_stats)
  
  # Check for missing data
  cat("\nMissing Data Summary:\n")
  print(colSums(is.na(data)))
}

# Main analysis function
main_analysis <- function() {
  # Process data
  data <- process_meta_data()
  
  # Print summary
  summarize_data(data)
  
  # Create separate datasets for each clinical group
  clinical_groups <- split(data, data$combined_clinical_group)
  
  # Return processed data and groups
  return(list(
    full_data = data,
    clinical_groups = clinical_groups
  ))
}

# Run the analysis
results <- main_analysis()

# Save processed data for further analysis
saveRDS(results, "processed_meta_data.rds")

# Basic data quality checks
quality_checks <- function(data) {
  # Check for extreme values
  cat("\nChecking for extreme effect sizes (|z| > 3):\n")
  extreme_effects <- data %>%
    filter(abs(fishers_z) > 3)
  print(extreme_effects[, c("study_id", "author", "fishers_z", "fishers_z_se")])
  
  # Check for unusually small standard errors
  cat("\nChecking for very small standard errors (se < 0.01):\n")
  small_se <- data %>%
    filter(fishers_z_se < 0.01)
  print(small_se[, c("study_id", "author", "fishers_z", "fishers_z_se")])
}

# Run quality checks
quality_checks(results$full_data)

# Print summary of belief categories by clinical group
belief_summary <- results$full_data %>%
  group_by(combined_clinical_group, belief_category) %>%
  summarize(
    n = n(),
    mean_effect = mean(fishers_z, na.rm = TRUE),
    .groups = 'drop'
  )

print("\nBelief Category Summary by Clinical Group:")
print(belief_summary)

######
# Further analyses
#####

# Load the processed data
results <- readRDS("processed_meta_data.rds")
data <- results$full_data

# First, let's examine the NA patterns
na_summary <- sapply(data, function(x) sum(is.na(x)))
print("NA Summary:")
print(na_summary)

# Clean data for analyses
data_clean <- data %>%
  # Remove rows where essential variables are NA
  filter(!is.na(fishers_z), !is.na(fishers_z_se), !is.na(combined_clinical_group))

# 1. Publication Bias Assessment
run_publication_bias <- function(data, group_name) {
  tryCatch({
    # Filter data for the group
    group_data <- data %>%
      filter(combined_clinical_group == group_name)
    
    # Fit random effects model
    res <- rma(yi = fishers_z, sei = fishers_z_se, data = group_data)
    
    # Egger's test
    egger <- regtest(res)
    
    # Trim and fill analysis
    tf <- trimfill(res)
    
    # Return results
    list(
      group = group_name,
      egger = egger,
      trim_fill = tf,
      k = nrow(group_data)
    )
  }, error = function(e) {
    message("Error in group: ", group_name)
    message(e)
    NULL
  })
}

# Run publication bias analysis for each group
groups <- unique(data_clean$combined_clinical_group)
pub_bias_results <- lapply(groups, function(g) {
  run_publication_bias(data_clean, g)
})
names(pub_bias_results) <- groups

# Print publication bias results
for(group in groups) {
  if(!is.null(pub_bias_results[[group]])) {
    cat("\nResults for group:", group, "\n")
    print(pub_bias_results[[group]]$egger)
    print(pub_bias_results[[group]]$trim_fill)
  }
}

# 2. Subgroup Analysis by Belief Category
# First, check belief category distribution
print("\nBelief Category Distribution:")
print(table(data_clean$belief_category, data_clean$combined_clinical_group))

# Run subgroup analysis
belief_subgroup <- rma(yi = fishers_z, 
                       sei = fishers_z_se,
                       mods = ~ belief_category - 1,
                       data = data_clean[!is.na(data_clean$belief_category),])

print("\nBelief Category Subgroup Analysis:")
print(belief_subgroup)

# 3. Meta-regression with proper NA handling
run_meta_regression <- function(data, moderator, moderator_name) {
  # Remove NAs for this specific moderator
  data_mod <- data[!is.na(data[[moderator]]), ]
  
  if(nrow(data_mod) < 10) {
    return(list(
      moderator = moderator_name,
      error = "Insufficient data",
      n = nrow(data_mod)
    ))
  }
  
  # Fit model
  mod <- try(rma(yi = fishers_z,
                 sei = fishers_z_se,
                 mods = as.formula(paste("~", moderator)),
                 data = data_mod))
  
  if(inherits(mod, "try-error")) {
    return(list(
      moderator = moderator_name,
      error = "Model fitting failed",
      n = nrow(data_mod)
    ))
  }
  
  return(list(
    moderator = moderator_name,
    model = mod,
    n = nrow(data_mod)
  ))
}

# Run meta-regressions
moderators <- list(
  mean_age = "Mean Age",
  percent_male = "Percent Male",
  year = "Publication Year",
  sample_size = "Sample Size"
)

meta_reg_results <- lapply(names(moderators), function(mod) {
  run_meta_regression(data_clean, mod, moderators[[mod]])
})
names(meta_reg_results) <- names(moderators)

# Print meta-regression results
for(mod in names(meta_reg_results)) {
  cat("\nMeta-regression results for:", moderators[[mod]], "\n")
  if(!is.null(meta_reg_results[[mod]]$model)) {
    print(meta_reg_results[[mod]]$model)
  } else {
    cat("Analysis failed:", meta_reg_results[[mod]]$error, "\n")
  }
  cat("Number of studies:", meta_reg_results[[mod]]$n, "\n")
}

# Save results
saveRDS(list(
  publication_bias = pub_bias_results,
  belief_subgroup = belief_subgroup,
  meta_regression = meta_reg_results,
  data_summary = list(
    total_studies = nrow(data_clean),
    na_summary = na_summary
  )
), "meta_analysis_results_corrected.rds")

# Basic visualization of subgroup effects
ggplot(data_clean[!is.na(data_clean$belief_category),], 
       aes(x = belief_category, y = fishers_z, color = combined_clinical_group)) +
  geom_boxplot() +
  theme_minimal() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1)) +
  labs(title = "Effect Sizes by Belief Category and Clinical Group",
       x = "Belief Category",
       y = "Fisher's Z")

ggsave("subgroup_effects.png", width = 12, height = 8)