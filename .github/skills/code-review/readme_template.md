# {{TITLE}}

{{DOI_BADGE}} {{LICENCE_BADGE}}

## Description

{{DESCRIPTION}}

## Abstract

{{ABSTRACT}}

## Instructions

This repository contains the code and data accompanying the manuscript above.
To reproduce the analysis:

1. Obtain the data as described under *Data files* below.
2. Restore the package environment (see *Dependencies*); if `renv.lock` is
   present, run `renv::restore()`.
3. Run the scripts in the order given under *Scripts*.

## Authors

| Name | ORCID | Affiliation |
|------|-------|-------------|
{{AUTHOR_ROWS}}

### Funding

{{FUNDING}}

## Data files

{{PER_FILE_SECTIONS}}

<!--
Each data file is rendered as:

### `<filename>`

Collected: <dates> at <locations>.

| Column | Type | Range / values | Description | Unit |
|--------|------|----------------|-------------|------|
| ...    | ...  | ...            | ...         | ...  |

Type is the class readr parses. Range is min to max for numeric columns,
or a count of distinct values otherwise.
-->

## Scripts

Run in the following order:

| Order | Script | Description |
|-------|--------|-------------|
{{SCRIPT_ROWS}}

## Dependencies

Built under R {{R_VERSION}}, with package versions pinned in `renv.lock`.
Restore the environment with `renv::restore()`.

| Package | Version |
|---------|---------|
{{PACKAGE_ROWS}}

## AI declaration

{{AI_DECLARATION}}
