# Data Cleaning Project

Cleans datasets from the "Human Activity Recognition Using Smartphones" dataset 
available that [UC Irvine has made available here](https://archive.ics.uci.edu/dataset/240/human+activity+recognition+using+smartphones).

## Requirements
Make sure you have the packages `reshape2` and `dplyr` installed in your R
environment.

## Usage
Running `Rscript run_analysis.R` will:
1. Download the dataset and unzip it into a directory called `UCI HAR Dataset`
if the directory does not yet exist.
2. Produce a clean dataset broken down into one row per observation and one 
column per variable. This is written to `full.txt`
3. Produce a second dataset, a summary of the first dataset containing the mean
of the observed feature value for each combination of feature, activity, and
subject. This is written to `summary.txt`

Please see the comments in `run_analysis.R` for a step-by-step breakdown of how
the datasets are built.

## Codebook
In the full dataset (`full.txt`), each row is an observation with the following 
variables:

* **id**: The ID of the trial. Several measurements are taken on each trial,
so each row contains a single observation of a single measurement. This ID 
corresponds to the line numbers in the "X_{set}.txt" and "y_{set}.txt" files.
Trial IDs are only unique within a set (e.g. both "train" and "test" sets can
have a trial ID of 1, 2, 3, etc.)
in the `UCI HAR Dataset/train/` and `UCI HAR Dataset/test/` directories.
* **subject**: The ID of the subject (person) under observation
* **set**: The set the observation comes from (either "train" or "test")
* **feature**: The feature whose measurement the row is based on. Please see
`UCI HAR Dataset/features_info.txt` for details on the features.
* **value**: The measured value of the **feature**

In the summary dataset (`summary.txt`), the mean value for each feature when
aggregated over activity and subject is recorded. For example, the first row is
contains the mean value of "tBodyAcc-mean()-X" for Subject 1 while they were 
LAYING. So the variables have the same meanings as above, but you'll only see: 
feature, activity, subject, and mean(value).
