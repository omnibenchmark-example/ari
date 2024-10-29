library(argparse)
library(readr)
library(dplyr)
library(mclust)

# Define argument parser
parser <- ArgumentParser(description="Calculate Adjusted Rand Index between clusters mapping and reference labels.")

# Add arguments
parser$add_argument("--output_dir", "-o", dest="output_dir", type="character", help="output directory where files will be saved", default=getwd())
parser$add_argument("--name", "-n", dest="name", type="character", help="name of the dataset", default="ari")
parser$add_argument('--methods.clusters', dest="clusters", type="character", help='clusters mapping', default=NULL)
parser$add_argument('--data.labels', dest="labels", type="character", help='reference labels', default=NULL)

# Parse command-line arguments
opt <- parser$parse_args()

# Check if mandatory argument are provided
if (is.null(opt$clusters) || is.null(opt$labels)) {
  stop("Error: Mandatory arguments --clusters and --labels are required.")
}

# Read the clusters and labels
clusters_df <- read_csv(opt$clusters)
labels_df <- read_csv(opt$labels)

# Merge the two data frames by 'id' to align labels with clusters
merged_df <- clusters_df %>%
  inner_join(labels_df, by = "id", suffix = c("_cluster", "_reference"))

# Extract the labels and cluster assignments
cluster_labels <- merged_df$label_cluster
reference_labels <- merged_df$label_reference

# Calculate Adjusted Rand Index (ARI)
ari_value <- adjustedRandIndex(cluster_labels, reference_labels)

# Output ARI to a file
output_file <- file.path(opt$output_dir, paste0(opt$name, ".metrics.txt"))
writeLines(as.character(ari_value), output_file)

cat("ARI calculated successfully. Results saved to:", output_file, "\n")
cat("ARI is:", ari_value, "\n")