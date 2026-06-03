# scan_packages.R ----
# Purpose: read renv.lock and print the R version and the package versions it
# pins. Used by: research-readme skill, Stage 4.

library(tidyverse)
library(jsonlite)

# read renv.lock and return R version plus a package/version tibble ----
read_lockfile <- function(lock_path = "renv.lock") {
  stopifnot(file.exists(lock_path))
  lock <- read_json(lock_path)

  r_version <- lock |> pluck("R", "Version", .default = NA_character_)

  packages_df <- lock |>
    pluck("Packages") |>
    map(\(p) tibble(package = p$Package, version = p$Version)) |>
    list_rbind() |>
    arrange(package)

  list(r_version = r_version, packages = packages_df)
}

# print R version and package table ----
print_lockfile <- function(lock_path = "renv.lock") {
  info <- read_lockfile(lock_path)
  cat(str_glue("R version: {info$r_version}\n\n"))
  print(info$packages, n = Inf)
}