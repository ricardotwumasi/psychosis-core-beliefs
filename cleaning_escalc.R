##############
# Data cleaning and effect size calculation 
###############

# Load required libraries with checks
required_packages <- c("tidyverse", "metafor")
lapply(required_packages, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
})

# Read data
data <- read.csv("meta_analysis151124.csv", stringsAsFactors = FALSE)

# Vectorized function to convert effect sizes to correlation coefficient (r)
convert_to_r <- Vectorize(function(es, es_type, n) {
  if(is.na(es) || is.na(es_type)) return(NA_real_)
  
  # Direct correlations
  if(es_type %in% c("spearmans_r", "pearsons_r", "spearman_r", "partial_correlation_coefficient")) {
    return(es)
  }
  
  # Odds ratio to r
  if(es_type == "odds_ratio") {
    logOR <- log(es)
    return(logOR / (sqrt(3) * pi))
  }
  
  # Cohen's d to r
  if(es_type == "cohens_d") {
    return(es / sqrt(es^2 + 4))
  }
  
  # Eta squared and partial eta squared to r
  if(es_type %in% c("eta_squared", "partial_eta_squared")) {
    return(sqrt(es))
  }
  
  # R-squared to r
  if(es_type == "r_squared") {
    return(sqrt(abs(es)) * sign(es))
  }
  
  # Chi-squared to r
  if(es_type == "chi_squared") {
    return(sqrt(es / n) * sign(es))
  }
  
  # Beta coefficients
  if(es_type %in% c("beta_coefficient", "beta_indirect_effect", "beta_total_effect")) {
    return(es)  # Already standardized
  }
  
  # F statistic to r
  if(es_type %in% c("f_statistic", "f_squared")) {
    return(sqrt(es / (es + n - 2)))  # Assuming simplest case
  }
  
  # T-test to r
  if(es_type == "t_test") {
    return(es / sqrt(es^2 + n - 2))
  }
  
  return(NA_real_)
})

# Clean and transform data
cleaned_data <- data %>%
  # First clean up belief types for BCSS
  mutate(
    belief_type = case_when(
      measure_type == "BCSS" & str_detect(belief_type, "negative_self|negative__self") ~ "negative_self",
      measure_type == "BCSS" & str_detect(belief_type, "negative_other|negative_others") ~ "negative_other",
      measure_type == "BCSS" & str_detect(belief_type, "positive_self") ~ "positive_self",
      measure_type == "BCSS" & str_detect(belief_type, "positive_other|positive_others") ~ "positive_other",
      TRUE ~ belief_type
    ),
    
    # Create combined measure_belief
    measure_belief = paste(measure_type, belief_type, sep="_"),
    
    # Standardize symptom categories
    symptom_category = case_when(
      str_detect(tolower(symptom_subtype), "grandiose") ~ "grandiose",
      str_detect(tolower(symptom_subtype), "persecut|paranoi") ~ "persecutory",
      str_detect(tolower(symptom_subtype), "voice|auditory|hallucin") ~ "voice_hearing",
      str_detect(tolower(symptom_subtype), "negative") ~ "negative_symptoms",
      TRUE ~ NA_character_
    ),
    
    # Standardize trauma categories
    trauma_category = case_when(
      str_detect(tolower(trauma_subtype), "physical_abuse") ~ "physical_abuse",
      str_detect(tolower(trauma_subtype), "emotional_abuse") ~ "emotional_abuse",
      str_detect(tolower(trauma_subtype), "sexual_abuse") ~ "sexual_abuse",
      str_detect(tolower(trauma_subtype), "physical_neglect") ~ "physical_neglect",
      str_detect(tolower(trauma_subtype), "emotional_neglect") ~ "emotional_neglect",
      TRUE ~ NA_character_
    )
  )

# Now handle effect size conversions row by row
cleaned_data$effect_size_r <- mapply(
  convert_to_r,
  cleaned_data$effect_size,
  cleaned_data$effect_size_type,
  cleaned_data$sample_size
)

# Calculate Fisher's z and SE
cleaned_data <- cleaned_data %>%
  mutate(
    fishers_z = atanh(effect_size_r),
    fishers_z_se = 1/sqrt(pmax(sample_size - 3, 1))  # pmax to avoid negative/zero values
  )

# Create separate datasets for each analysis
# 1. BCSS Core Beliefs by Clinical Group
bcss_clinical <- cleaned_data %>%
  filter(
    measure_type == "BCSS",
    belief_type %in% c("negative_self", "negative_other", "positive_self", "positive_other"),
    !is.na(combined_clinical_group)
  )

# 2. BCSS Core Beliefs by Symptom Type
bcss_symptoms <- cleaned_data %>%
  filter(
    measure_type == "BCSS",
    !is.na(symptom_category)
  )

# 3. BCSS Core Beliefs by Trauma Type
bcss_trauma <- cleaned_data %>%
  filter(
    measure_type == "BCSS",
    !is.na(trauma_category)
  )

# 4. YSQ Analysis
ysq_data <- cleaned_data %>%
  filter(
    measure_type %in% c("YSQ", "YSQ_SF")
  )

# Save cleaned datasets
write.csv(cleaned_data, "cleaned_meta_analysis.csv", row.names = FALSE)
write.csv(bcss_clinical, "bcss_clinical_groups.csv", row.names = FALSE)
write.csv(bcss_symptoms, "bcss_symptoms.csv", row.names = FALSE)
write.csv(bcss_trauma, "bcss_trauma.csv", row.names = FALSE)
write.csv(ysq_data, "ysq_analysis.csv", row.names = FALSE)

# Generate summary statistics
summary_stats <- list(
  clinical_groups = bcss_clinical %>%
    group_by(combined_clinical_group, belief_type) %>%
    summarise(
      n_studies = n(),
      mean_z = mean(fishers_z, na.rm = TRUE),
      sd_z = sd(fishers_z, na.rm = TRUE),
      .groups = "drop"
    ),
  
  symptoms = bcss_symptoms %>%
    group_by(symptom_category, belief_type) %>%
    summarise(
      n_studies = n(),
      mean_z = mean(fishers_z, na.rm = TRUE),
      sd_z = sd(fishers_z, na.rm = TRUE),
      .groups = "drop"
    ),
  
  trauma = bcss_trauma %>%
    group_by(trauma_category, belief_type) %>%
    summarise(
      n_studies = n(),
      mean_z = mean(fishers_z, na.rm = TRUE),
      sd_z = sd(fishers_z, na.rm = TRUE),
      .groups = "drop"
    )
)

# Print summaries
cat("\nSummary by Clinical Groups:\n")
print(summary_stats$clinical_groups)
cat("\nSummary by Symptoms:\n")
print(summary_stats$symptoms)
cat("\nSummary by Trauma:\n")
print(summary_stats$trauma)

# Basic validity checks
validity_checks <- cleaned_data %>%
  summarise(
    total_rows = n(),
    missing_es = sum(is.na(effect_size_r)),
    invalid_z = sum(abs(fishers_z) > 4, na.rm = TRUE),  # Flag very large z values
    missing_se = sum(is.na(fishers_z_se))
  )

cat("\nValidity Checks:\n")
print(validity_checks)

################
# verification #
#################

# Read cleaned data
cleaned_data <- read.csv("cleaned_meta_analysis.csv")

# Check conversion results by effect size type
conversion_check <- cleaned_data %>%
  group_by(effect_size_type) %>%
  summarise(
    n = n(),
    original_range = paste(round(min(effect_size, na.rm = TRUE), 3),
                           "to",
                           round(max(effect_size, na.rm = TRUE), 3)),
    r_range = paste(round(min(effect_size_r, na.rm = TRUE), 3),
                    "to",
                    round(max(effect_size_r, na.rm = TRUE), 3)),
    z_range = paste(round(min(fishers_z, na.rm = TRUE), 3),
                    "to",
                    round(max(fishers_z, na.rm = TRUE), 3)),
    mean_r = mean(effect_size_r, na.rm = TRUE),
    mean_z = mean(fishers_z, na.rm = TRUE)
  )

# Check BCSS categorization
bcss_check <- cleaned_data %>%
  filter(measure_type == "BCSS") %>%
  group_by(belief_type) %>%
  summarise(
    n = n(),
    mean_z = mean(fishers_z, na.rm = TRUE),
    sd_z = sd(fishers_z, na.rm = TRUE)
  )

# Check symptom categorization
symptom_check <- cleaned_data %>%
  filter(!is.na(symptom_category)) %>%
  group_by(symptom_category) %>%
  summarise(
    n = n(),
    mean_z = mean(fishers_z, na.rm = TRUE),
    sd_z = sd(fishers_z, na.rm = TRUE)
  )

# Check trauma categorization
trauma_check <- cleaned_data %>%
  filter(!is.na(trauma_category)) %>%
  group_by(trauma_category) %>%
  summarise(
    n = n(),
    mean_z = mean(fishers_z, na.rm = TRUE),
    sd_z = sd(fishers_z, na.rm = TRUE)
  )

# Print results
cat("\nEffect Size Conversion Check:\n")
print(conversion_check)

cat("\nBCSS Belief Type Check:\n")
print(bcss_check)

cat("\nSymptom Category Check:\n")
print(symptom_check)

cat("\nTrauma Category Check:\n")
print(trauma_check)

# Check for potential outliers or problematic conversions
outliers <- cleaned_data %>%
  filter(abs(fishers_z) > 2) %>%  # Flag large effect sizes
  select(study_id, author, effect_size_type, effect_size, effect_size_r, fishers_z)

cat("\nPotential outliers (|z| > 2):\n")
print(outliers)

# Distribution plots
library(ggplot2)

# Fisher's z distribution by measure type
p1 <- ggplot(cleaned_data, aes(x = fishers_z)) +
  geom_histogram(bins = 30) +
  facet_wrap(~measure_type) +
  theme_minimal() +
  labs(title = "Distribution of Fisher's z by Measure Type",
       x = "Fisher's z",
       y = "Count")

# Fisher's z distribution by clinical group (BCSS only)
p2 <- cleaned_data %>%
  filter(measure_type == "BCSS") %>%
  ggplot(aes(x = fishers_z, fill = combined_clinical_group)) +
  geom_density(alpha = 0.5) +
  theme_minimal() +
  labs(title = "Distribution of Fisher's z by Clinical Group (BCSS only)",
       x = "Fisher's z",
       y = "Density")

# Save plots
ggsave("fishers_z_by_measure.png", p1)
ggsave("fishers_z_by_group.png", p2)
