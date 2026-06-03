# C. elegans Reproduction Analysis

<!-- TODO: supply [paper DOI badge] — not provided; do not leave in final submission -->
<!-- TODO: supply [code/data archive DOI badge, e.g. OSF or Zenodo] — not provided; do not leave in final submission -->
<!-- TODO: supply [licence badge] — not provided; do not leave in final submission -->

## Description

This repository contains the R code and data for a factorial experiment examining how **strain** (RNAi knockdown `daf` vs. `empty_vector` negative control) and **diet** (ad libitum `AL` vs. every-other-day fasting `EODF`) affect total reproductive output in the nematode *Caenorhabditis elegans*. Worms were raised across replicate blocks; total offspring per individual is the response variable. The primary analysis uses a generalised linear mixed model with a negative binomial response to account for overdispersed count data, with experimental block as a random intercept.

## Abstract

<!-- TODO: supply [abstract from the accompanying manuscript] — not provided; do not leave in final submission -->

## Instructions

To reproduce the analysis:

1. Clone or download this repository.
2. Restore the R package environment (see *Dependencies*).  
   If `renv.lock` is present: open R in the project root and run `renv::restore()`.
   <!-- TODO: run renv::init() and renv::snapshot() to generate renv.lock before archiving -->
3. Run the scripts in the order given under *Scripts*.

## Authors

| Name | ORCID | Affiliation |
|------|-------|-------------|
| <!-- TODO: supply [author name] --> | <!-- TODO: supply [ORCID] --> | <!-- TODO: supply [affiliation] --> |

### Funding

<!-- TODO: supply [funder name(s) and grant number(s)] — not provided; do not leave in final submission -->

## Data files

### `celegans_repro_raw.csv`

<!-- TODO: supply [collection dates] and [collection location / lab] -->

Raw individual-level observations from the *C. elegans* reproduction experiment, before any exclusion or cleaning. Contains 293 data rows (294 lines including header).

| Column | Type | Range / values | Description | Unit |
|--------|------|----------------|-------------|------|
| `worm_id` | integer | 1 to 506 (2 rows are NA) | Unique identifier for each individual worm | — |
| `B` | integer | 1 to 6 (some rows NA) | Experimental block <!-- TODO: confirm this is "block"; rename to `block` for clarity --> | — |
| `strain` | character | "daf", "empty_vector" (and inconsistent variants "DAF", "empty_vector ") | RNAi strain; requires standardisation before analysis (see CODE_REVIEW.md B7–B8) | — |
| `diet` | character | "AL", "EODF" (and inconsistent variant "eodf") | Dietary treatment; ad libitum (`AL`) or every-other-day fasting (`EODF`); requires standardisation (see CODE_REVIEW.md B8) | — |
| `TO` | integer | −46 to 9999 | Total offspring count per worm <!-- TODO: confirm unit is count of offspring; rename to `total_offspring` for clarity -->. Contains one biologically impossible value (−46) and three sentinel values (9999) that must be resolved before analysis (see CODE_REVIEW.md B9–B10) | count |

**Known data quality issues requiring resolution before analysis:**
- Three rows with `TO = 9999` (apparent missing-data sentinel, worm_ids 200–202)
- One row with `TO = -46` (biologically impossible, worm_id 112)
- Six rows (worm_ids 501–506) with `B`, `strain`, and `diet` all NA
- Two rows with `worm_id = NA`
- Case inconsistencies in `strain` ("daf" vs "DAF") and `diet` ("EODF" vs "eodf")
- Trailing whitespace in some `strain` values ("empty\_vector ")

---

### `celegans_repro_final.csv`

<!-- TODO: supply [collection dates] and [collection location / lab] -->

Derived dataset produced from `celegans_repro_raw.csv` after exclusions. Contains 245 data rows (246 lines including header). All block 3 observations are absent compared to the raw file; the exclusion criterion is not currently documented — see CODE_REVIEW.md M9.

| Column | Type | Range / values | Description | Unit |
|--------|------|----------------|-------------|------|
| `worm_id` | integer | 1 to 293 | Unique identifier for each individual worm | — |
| `B` | integer | 1 to 6 | Experimental block <!-- TODO: confirm and rename to `block` --> | — |
| `strain` | character | "daf", "empty_vector" (with same inconsistencies as raw) | RNAi strain | — |
| `diet` | character | "AL", "EODF", "eodf" | Dietary treatment | — |
| `TO` | integer | <!-- TODO: supply range after resolving sentinel/negative values --> | Total offspring count per worm | count |

## Scripts

Run in the following order:

| Order | Script | Description |
|-------|--------|-------------|
| — | `old_code.R` | **Historical reference only — do not execute.** Early exploratory draft; contains absolute paths and other non-reproducible practices. Retained for provenance; should be removed or archived separately before final submission. |
| — | `ANALYSIS.R` | Draft analysis script. Currently non-executable due to absolute paths, missing data files, and syntax errors (see CODE_REVIEW.md). Requires substantial revision before use. |
| 1 | `celegans_analysis.Rmd` | Main analysis document. Fits negative binomial GLMMs, compares models by AIC and likelihood ratio test, produces post-hoc contrasts (emmeans), and visualises results. **Note:** currently generates simulated data internally rather than reading from the CSV files; see CODE_REVIEW.md B4 for the required fix. Renders to `celegans_analysis.html`. |

<!-- TODO: add a data-cleaning script (e.g. 01_clean.R) that reproducibly produces celegans_repro_final.csv from celegans_repro_raw.csv with all exclusion criteria documented -->

## Dependencies

<!-- TODO: run renv::init() and renv::snapshot() to produce renv.lock, then update this section -->

No `renv.lock` is present in this repository. The R version and exact package versions are not currently pinned. Before archiving, run `renv::init()` followed by `renv::snapshot()` in the project root to generate `renv.lock`, then commit it.

Packages known to be used by `celegans_analysis.Rmd`:

| Package | Purpose |
|---------|---------|
| tidyverse | Data manipulation and plotting |
| lme4 | Mixed-effects model fitting (`glmer.nb`) |
| lmerTest | p-values for mixed models |
| emmeans | Post-hoc pairwise contrasts |
| DHARMa | GLMM residual diagnostics |
| ThemePark | Plot theme (see CODE_REVIEW.md M3 — should be replaced) |

<!-- TODO: add full pinned package table from renv.lock after renv::snapshot() -->

## AI declaration

This README was generated with the assistance of a GitHub Copilot AI agent on <!-- TODO: insert date -->. The agent read repository files to populate known fields and inserted explicit placeholders for all metadata not present in the repository. All scientific content, metadata (DOIs, ORCIDs, affiliations, funding, variable units, collection dates and locations), and final editorial decisions remain the responsibility of the authors. The agent did not modify any `.R`, `.Rmd`, or data file in this repository.
