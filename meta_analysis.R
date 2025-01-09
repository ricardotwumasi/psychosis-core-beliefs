##############
# Meta analysis
###############

# Load required libraries with checks
required_packages <- c("tidyverse", "metafor")
lapply(required_packages, function(pkg) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
  library(pkg, character.only = TRUE)
})

# Read the data (change for each BCSS and YSQ variable csv or use Loop to Generate Individual Forest Plots and Save Them)
data <- read.csv("BCSS/CHR_BCSS_Positive_Other.csv")

# List of CSV files for looping
#files <- c("SZ_BCSS_Negative_Self.csv", "SZ_BCSS_Positive_Self.csv",
#           "SZ_YSQ_Abandonment.csv", "SZ_YSQ_Mistrust.csv") etc

# Standardize control group naming 
data$clinical_group <- tolower(data$clinical_group)

# Create separate dataframes for SZ and control groups (swap to 'chr' for clinical high risk)
sz_data <- data[data$clinical_group == "sz", ]
control_data <- data[data$clinical_group == "control", ]

# Calculate effect sizes (swap to 'chr' for clinical high risk)
es <- escalc(measure="SMD",      
             n1i=sz_data$sample_size,        
             n2i=control_data$sample_size,    
             m1i=sz_data$mean_score,         
             m2i=control_data$mean_score,     
             sd1i=sz_data$sd,                
             sd2i=control_data$sd)           

# Fit random effects model with REML and Knapp-Hartung adjustments
res <- rma(yi = es$yi,          
           vi = es$vi,          
           method = "REML",     
           test = "knha")       

# Calculate weights
weights <- weights(res)
formatted_weights <- sprintf("%.1f", weights)

forest(res,
       slab = paste(chr_data$author, chr_data$year),
       header = "Study",
       xlab = "Standardized Mean Difference (d)",
       ilab = formatted_weights,
       ilab.xpos = -3.2,
       xlim = c(-5, 2.5),
       alim = c(-3, 1),
       at = seq(-3, 1, 0.5),
       steps = 7,
       refline = 0,
       main = "BCSS Positive Other SZ vs Healthy Control",
       cex = 0.9,
       mlab = "RE Model",
       ilab.pos = 4,
       psize = 1.2)  

# Add weight column header
text(-3.2, res$k+2, "Weight (%)", cex = 0.9)

# Print RE model pooled estimate
cat("\nRandom Effects Model Estimate:\n")
cat(sprintf("%.2f [%.2f, %.2f]\n", res$b[1], res$ci.lb, res$ci.ub))

# Print model and heterogeneity statistics
cat("\nModel Statistics:\n")
cat("Q statistic:", sprintf("%.2f", res$QE), "\n")
cat("Q p-value:", sprintf("%.2f", res$QEp), "\n")
cat("I^2:", sprintf("%.2f", res$I2), "%\n")
cat("τ²:", sprintf("%.2f", res$tau2), "\n")

# Calculate and print prediction interval
pi <- predict(res)
cat("\nPrediction Interval:\n")
cat("Lower bound:", sprintf("%.2f", pi$cr.lb), "\n")
cat("Upper bound:", sprintf("%.2f", pi$cr.ub), "\n")
