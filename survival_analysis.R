# install.packages("readxl")
library(readxl)
# library(survival)
# install.packages("survminer")
# library(survminer)
clinical_data <- read_excel("CroatMedJ_57_s002.xls", sheet = "DATA")

head(clinical_data)

# Summary of each column to see where NAs are and how many
summary(clinical_data)

# Alternatively, to get the number of NAs in each column
sapply(clinical_data, function(x) sum(is.na(x)))
# Row NAs
# clinical_data <- na.omit(clinical_data)
# col NAs
# clinical_data <- clinical_data[, colSums(is.na(clinical_data)) < threshold]

#Impute
# Mean imputation (replace with median or mode if more appropriate)
if(is.numeric(clinical_data$`light ch`)) {
  clinical_data$`light ch`[is.na(clinical_data$`light ch`)] <- mean(clinical_data$`light ch`, na.rm = TRUE)
}

# round the 'light ch' col
clinical_data$`light ch` <- round(clinical_data$`light ch`)
str(clinical_data)

clinical_data$`age gr` <- as.factor(clinical_data$`age gr`)
clinical_data$`heavy ch` <- as.factor(clinical_data$`heavy ch`)
clinical_data$`light ch` <- as.factor(clinical_data$`light ch`)
clinical_data$ISS <- as.factor(clinical_data$ISS)
clinical_data$`Renal function` <- as.factor(clinical_data$`Renal function`)

# survival analyses
# 1. Kaplan-Meier Estimation
# Load necessary libraries
library(survival)
library(survminer)

# Create a survival object
surv_obj <- Surv(time = clinical_data$OS, event = clinical_data$status)

# Kaplan-Meier estimate
# Replace 'sex' with your chosen grouping variable if different
km_fit <- survfit(surv_obj ~ sex, data = clinical_data)
summary(km_fit)
# Plotting the Kaplan-Meier survival curve
ggsurvplot(km_fit, data = clinical_data, pval = TRUE, conf.int = TRUE)

# 2. Cox Proportional Hazards Model/ Cox Regression

# Cox regression
clinical_data$sex <- as.factor(clinical_data$sex)

# Include the covariates you're interested in
cox_fit <- coxph(Surv(OS, status) ~ sex + age + `light ch` + ISS, data = clinical_data)

# Summary of the Cox model
summary(cox_fit)
# Checking Proportional Hazards Assumption
# Rename variable for simplicity
names(clinical_data)[names(clinical_data) == "light ch"] <- "light_ch"

# Rebuild Cox model with updated variable names
cox_fit <- coxph(Surv(OS, status) ~ sex + age + light_ch + ISS, data = clinical_data)

# Try ggforest again
ggforest(cox_fit, data = clinical_data)



# 3. Log-Rank Test
# Log-Rank Test
# Replace 'sex' with the grouping variable you want to test
surv_diff <- survdiff(surv_obj ~ sex, data = clinical_data)

# Print the results
print(surv_diff)
# Kaplan-Meier estimate highlighting Log-Rank Test
km_fit_groups <- survfit(surv_obj ~ sex, data = clinical_data)
ggsurvplot(km_fit_groups, data = clinical_data, pval = TRUE, conf.int = TRUE, risk.table = TRUE)



cox_fit <- coxph(Surv(OS, status) ~ sex + age + light_ch + ISS, data = clinical_data)
ggforest(cox_fit, data = clinical_data)

# Before potential modification
summary(clinical_data)

# [Code that might modify clinical_data]

# After potential modification
summary(clinical_data)

model_vars <- names(coef(cox_fit))
data_vars <- names(clinical_data)
is_subset <- all(model_vars %in% data_vars)
if(is_subset) {
  print("All variable names in the Cox model are present in the dataset.")
} else {
  print("Some variable names in the Cox model are missing in the dataset.")
}

# Variable names used in the Cox model
cox_model_vars <- all.vars(formula(cox_fit))

# Variable names in the dataset
dataset_vars <- names(clinical_data)

# Identify missing variables
missing_vars <- setdiff(cox_model_vars, dataset_vars)

# Print missing variables
print(missing_vars)

# Checking data types for each variable
str(clinical_data)
cox_fit <- coxph(Surv(OS, status) ~ sex + age + light_ch + ISS, data = clinical_data)
# Checking proportional hazards assumption
test_ph <- cox.zph(cox_fit)
plot(test_ph)
# Reviewing the model formula
formula(cox_fit)

# Checking the dataset
str(clinical_data)
# Creating a simpler Cox model
simple_cox_fit <- coxph(Surv(OS, status) ~ age, data = clinical_data)
# Attempting to visualize the simpler model
ggforest(simple_cox_fit, data = clinical_data)

