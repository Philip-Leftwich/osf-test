# describe_csv.R ----
# Purpose: produce a simple one-row-per-column table describing a CSV file:
# column name, parsed type, and a brief range (numeric) or distinct-value
# count (other). Reports the type readr assigns, so it matches what the
# analysis scripts receive when they read the same file.
# Used by: research-readme skill, Stage 2.
 
library(tidyverse)
 
# one-row-per-column summary of a single CSV ----
describe_csv <- function(path) {
  stopifnot(is.character(path), length(path) == 1L, file.exists(path))
  data_df <- read_csv(path, show_col_types = FALSE)
  tibble(
    file = basename(path),
    column = names(data_df),
    type = map_chr(data_df, \(x) class(x)[1]),
    range = map_chr(data_df, \(x) {
      if (is.numeric(x)) {
        str_glue("{min(x, na.rm = TRUE)} to {max(x, na.rm = TRUE)}")
      } else {
        str_glue("{n_distinct(x)} unique values")
      }
    }),
    # placeholders the user completes during Stage 2:
    description = NA_character_,
    unit = NA_character_
  )
}
 
# describe every CSV under a folder ----
describe_project_csvs <- function(project_dir) {
  stopifnot(dir.exists(project_dir))
  csv_paths <- list.files(
    project_dir,
    pattern = "\\.csv$",
    recursive = TRUE,
    full.names = TRUE,
    ignore.case = TRUE
  )
  if (length(csv_paths) == 0L) {
    message("No CSV files found under ", project_dir)
    return(tibble())
  }
  csv_paths |>
    map(describe_csv) |>
    list_rbind()
}