library(reshape2)
library(dplyr)

datadir <- "UCI HAR Dataset"

# Fetch and unzip data if we don't already have it
if (!dir.exists(datadir)) {
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl, "uci_har_dataset.zip")
  unzip("uci_har_dataset.zip")
}

# Removes digits from a vector
removedigits <- function(x) {
  sub("[0-9]* ", "", x, perl = TRUE)
}

# Load and clean activity labels
con <- file(paste(datadir, "activity_labels.txt", sep = "/"), "r")
activity_labels <- readLines(con)
close(con)
activity_labels <- Map(removedigits, activity_labels)
activity_labels <- unlist(activity_labels, use.names = FALSE)

# Load features
con <- file(paste(datadir, "features.txt", sep = "/"), "r")
features <- readLines(con)
close(con)

# Clean feature names by removing digit
features <- Map(removedigits, features)

# Normalize to character vector
features <- unlist(features, use.names = FALSE)

# Only keep those with "mean" and "std" in the name
indices <- which(grepl("mean", features) | grepl("std", features))
features <- features[indices]

# Filters each line down to just those for the desired features
process_value_line <- function(line) {
  vals <- strsplit(line, " ")[[1]]
  vals <- as.numeric(vals)
  vals <- vals[!is.na(vals)]
  vals[indices]
}

# Main function to build the dataset
build_dataset <- function(set) {
  # build file paths
  subject_filename <- paste("subject_", set, ".txt", sep = "")
  label_filename <- paste("y_", set, ".txt", sep = "")
  value_filename <- paste("X_", set, ".txt", sep = "")
  subject_file <- paste(datadir, set, subject_filename, sep = "/")
  label_file <- paste(datadir, set, label_filename, sep = "/")
  value_file <- paste(datadir, set, value_filename, sep = "/")

  # Load subjects
  con <- file(subject_file, "r")
  subjects <- as.numeric(readLines(con))
  close(con)

  # Load activity labels
  con <- file(label_file, "r")
  y <- readLines(con)
  close(con)
  y <- as.numeric(y)
  activities <- sapply(y, function(x) {
    activity_labels[x]
  })

  # Create data frame
  data <- data.frame(
    "set" = set,
    "subject" = subjects,
    "activity" = activities
  )

  # initialize columns (we'll add the data later)
  data[, "id"] <- NA
  data[, features] <- NA

  # The measurements
  con <- file(value_file, "r")
  lines <- readLines(con)
  close(con)
  lines <- Map(process_value_line, lines)

  # For each line, set the ID of the trial and the value for each feature
  for (i in seq_along(lines)) {
    data[i, "id"] <- i
    for (j in seq_along(lines[[i]])) {
      label <- features[j]
      data[i, label] <- lines[[i]][j]
    }
  }

  # Melt such that each feature is on a separate row
  melted <- melt(
    data,
    id = c("id", "subject", "activity", "set"),
    variable.name = "feature"
  )

  # Sort by the trial ID
  arrange(melted, id)
}

test_data <- build_dataset("test")
train_data <- build_dataset("train")

# Combine data frames vertically
merged <- rbind(test_data, train_data)
write.table(merged, "full.txt", row.names = FALSE)

# Group by feature, activity, and subject. Then we can get the mean for each
# feature for each combination.
grouped <- group_by(merged, feature, activity, subject)
summary <- dplyr::summarize(grouped, mean(value))
write.table(summary, "summary.txt", row.names = FALSE)
