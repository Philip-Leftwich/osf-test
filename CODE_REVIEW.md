# Code Review Report — osf-test

> **Scope:** `ANALYSIS.R`, `old_code.R`, `celegans_analysis.Rmd`, `celegans_repro_raw.csv`, `celegans_repro_final.csv`  
> **Standards applied:** `.github/copilot-instructions.md` (reproducibility, naming, pipe style, data integrity, figure rules)  
> **Note on `old_code.R`:** treated as historical reference code; issues are catalogued for awareness but it should either be deleted before archiving or clearly labelled as non-executable.

---

## Summary table

| Severity | Count | Description |
|----------|-------|-------------|
| 🔴 Blocking | 10 | Prevents any external user reproducing the analysis |
| 🟠 Major | 13 | High risk of silent errors or misleading results |
| 🟡 Minor | 6 | Style and maintainability violations |

---

## 🔴 Blocking issues

### B1 — Absolute paths throughout `ANALYSIS.R` and `old_code.R`

**Files:** `ANALYSIS.R` lines 26, 36, 38, 79 · `old_code.R` lines 16  
**Issue:** Every path is hard-coded to a specific machine (`~/Library/CloudStorage/OneDrive-UniversityofGlasgow/…`). The scripts cannot be run on any other computer, CI environment, or archive clone.  
**Fix:** Replace all paths with `here::here("relative/path/to/file")`. Ensure `here` is loaded at the top.

---

### B2 — Referenced data files do not exist in the repository

**File:** `ANALYSIS.R` lines 26, 38  
**Issue:** The script reads from `celegans_raw.csv` and `celegans_datafinal.csv`, neither of which is present in the repository. The repository contains `celegans_repro_raw.csv` and `celegans_repro_final.csv`. The analysis cannot run as written.  
**Fix:** Update file references to match the files that are actually committed (`celegans_repro_raw.csv`, `celegans_repro_final.csv`), or rename the committed files to match the script.

---

### B3 — `libray()` typos cause immediate runtime errors

**File:** `ANALYSIS.R` lines 23–24  
**Issue:** `libray(tidyverse)` and `libray(hablar)` are misspellings of `library()`. R will throw `Error: could not find function "libray"` and halt before any analysis runs.  
**Fix:** Correct to `library(tidyverse)` and `library(hablar)`.

---

### B4 — `celegans_analysis.Rmd` generates simulated data instead of reading the repository data

**File:** `celegans_analysis.Rmd` lines 26–57 (`data-generation` chunk)  
**Issue:** The Rmd creates data from scratch using `rnbinom()` with hardcoded parameters. It does not read from either CSV file in the repository. Every render produces a different dataset (the seed fixes the values only within a session; the parameters themselves are researcher-chosen, not measured). This severs the link between raw data and reported results — the core requirement of a reproducible research archive.  
**Fix:** Replace the `data-generation` chunk with a data-import chunk that reads `celegans_repro_final.csv` using `readr::read_csv()`, applies any necessary cleaning (see data issues B7–B10 below), and documents each step.

---

### B5 — `%>%` pipe used instead of native `|>` pipe

**File:** `ANALYSIS.R` lines 32, 44–47  
**Issue:** `.github/copilot-instructions.md` mandates the native pipe `|>`. The magrittr pipe `%>%` requires the `magrittr` or `tidyverse` package and is also a CI gate that blocks merging.  
**Fix:** Replace all `%>%` with `|>`.

---

### B6 — `read.csv()` and `write.csv()` used instead of `readr` functions

**File:** `ANALYSIS.R` lines 26, 36, 38  
**Issue:** `.github/copilot-instructions.md` requires `readr::read_*(col_types = ...)`. `read.csv()` does not enforce column types and silently coerces mixed-type columns.  
**Fix:** Replace with `readr::read_csv("path", col_types = cols(...))` and `readr::write_csv()`.

---

### B7 — Inconsistent case in `strain` column (`celegans_repro_raw.csv`)

**File:** `celegans_repro_raw.csv` rows 145–216  
**Issue:** The `strain` column contains both `"daf"` and `"DAF"` (24 rows). R treats these as two separate factor levels, silently splitting what should be one experimental group.  
**Fix:** Standardise to lowercase `"daf"` across the raw file (or apply `stringr::str_to_lower()` at import with a documented rationale comment).

---

### B8 — Inconsistent case and trailing whitespace in `strain`/`diet`

**File:** `celegans_repro_raw.csv`  
**Issue:**  
- `diet` column contains both `"eodf"` and `"EODF"` (rows 134–143 and scattered rows in blocks 2–3).  
- `strain` column contains `"empty_vector "` with a trailing space (rows 61–72, block 1). This creates a phantom factor level that will silently be dropped by most `filter()` calls.  
**Fix:** Standardise all values at import using `stringr::str_trim()` and `stringr::str_to_lower()` (or `stringr::str_to_upper()`), documented in the cleaning chunk.

---

### B9 — Sentinel value `9999` used as missing data indicator

**File:** `celegans_repro_raw.csv` rows 200–202 (worm_ids 200–202, block 2, `empty_vector`, `EODF`)  
**Issue:** Three rows have `TO = 9999`, which is not a plausible offspring count for *C. elegans*. This appears to be a missing data sentinel. If not caught, these will inflate means and distort model estimates dramatically (a value of 9999 vs typical ~200 offspring).  
**Fix:** Replace `9999` with `NA` in the raw file and document the substitution, or handle at import with `dplyr::na_if(TO, 9999)` and a `# DEFAULT:` comment.

---

### B10 — Biologically impossible negative offspring count

**File:** `celegans_repro_raw.csv` row with `worm_id = 112`, block 5, `daf`, `EODF`, `TO = -46`  
**Issue:** Total offspring cannot be negative. This value is either a data entry error or a sign-encoded measurement of something else. If included in a negative binomial model it will cause convergence failure or distort the fit.  
**Fix:** Investigate the source record. If it is a data entry error, correct it. If unexplainable, replace with `NA` and document the exclusion in both the data file and the cleaning chunk.

---

## 🟠 Major issues

### M1 — Operator precedence bug in `filter()` call

**File:** `ANALYSIS.R` line 44–47  
**Issue:**
```r
filter(strain == "daf" | strain == "empty_vector" & !is.na(diet))
```
`&` binds more tightly than `|`, so this evaluates as:
```r
filter(strain == "daf" | (strain == "empty_vector" & !is.na(diet)))
```
All `daf` rows pass regardless of whether `diet` is NA. This is almost certainly not the intended logic. If the intent is to require non-NA diet for both strains, use:
```r
dplyr::filter((strain == "daf" | strain == "empty_vector") & !is.na(diet))
```
**Severity:** This changes which rows are analysed and can silently alter model estimates.

---

### M2 — Silent missing-data removal with `complete.cases()`

**File:** `ANALYSIS.R` line 34  
**Issue:** `full.dat <- dat2[complete.cases(dat2$\`total offspring\`), ]` drops NA rows without any comment explaining which rows are dropped or why. `.github/copilot-instructions.md` requires named-column `tidyr::drop_na()` with a stated reason.  
**Fix:**
```r
# Exclude rows where total offspring was not recorded (equipment failure, worm escape)
full_dat_df <- dat2_df |> tidyr::drop_na(total_offspring)
```

---

### M3 — Plot theme violates style guide

**File:** `celegans_analysis.Rmd` line 124  
**Issue:** `ThemePark::theme_barbie()` is used. `.github/copilot-instructions.md` explicitly prohibits `theme_grey()` and specifies `theme_minimal()` or `theme_classic()`. A bespoke theme from a novelty package is inappropriate for archiving or publication.  
**Fix:** Replace with `theme_classic()` or `theme_minimal()`.

---

### M4 — Plot uses colour only, without shape or linetype

**File:** `celegans_analysis.Rmd` lines 121–124  
**Issue:** `aes(colour = strain)` provides no second discriminator. `.github/copilot-instructions.md` states: "For categorical groups, add `shape` or `linetype` alongside colour." This affects accessibility (colour-blind readers) and greyscale print reproduction.  
**Fix:** Add `aes(x = diet, y = total_offspring, colour = strain, shape = strain)`.

---

### M5 — No model assumption check with `performance::check_model()`

**File:** `celegans_analysis.Rmd`  
**Issue:** `.github/copilot-instructions.md` requires `performance::check_model()` for regression models with the inspection recorded. DHARMa's `simulateResiduals()` is a good diagnostic for GLMMs but is not a substitute for the mandated check.  
**Fix:** Add a diagnostics chunk: `performance::check_model(m_full)`.

---

### M6 — Columns in CSV named `B` and `TO`; scripts reference different names

**File:** `celegans_repro_raw.csv`, `celegans_repro_final.csv`  
**Issue:** The CSV headers are `worm_id, B, strain, diet, TO`. `ANALYSIS.R` references `dat1$block` and `dat1$total_offspring` — neither column exists under those names in the actual data files. Any script reading these CSVs will produce `NULL` columns silently.  
**Fix:** Rename columns in the raw file (`B → block`, `TO → total_offspring`) or rename them at import using `readr::read_csv(col_names = c(...))` or `dplyr::rename()`.

---

### M7 — Rows with all-NA metadata cannot contribute to any factorial model

**File:** `celegans_repro_raw.csv` rows 501–506 (worm_ids 501–506)  
**Issue:** Six rows have valid `TO` values but `block`, `strain`, and `diet` all recorded as `NA`. They cannot be included in any mixed model. Their origin and whether they represent a distinct experimental group is undocumented.  
**Fix:** Investigate and either assign correct metadata or document their exclusion in the cleaning chunk.

---

### M8 — Two rows with `worm_id = NA`

**File:** `celegans_repro_raw.csv`  
**Issue:** Two rows (block 1, `daf`, `EODF`) have `worm_id = NA` but otherwise valid data. Missing IDs prevent linking these observations to any upstream lab record.  
**Fix:** Assign correct IDs if known, or document the ambiguity and flag the rows for exclusion.

---

### M9 — Block 3 entirely absent from `celegans_repro_final.csv`

**File:** `celegans_repro_raw.csv` vs `celegans_repro_final.csv`  
**Issue:** The diff shows all 48 block 3 rows were removed from the final dataset. No exclusion criterion, cleaning script, or documentation records why block 3 was dropped. This is an undocumented analytical decision that affects results.  
**Fix:** Add a dedicated data-cleaning script (e.g. `01_clean.R`) that reads the raw CSV and produces the final CSV with every exclusion step explicitly documented.

---

### M10 — `library(lme4)` loaded twice; ~15 unused packages loaded

**File:** `ANALYSIS.R` lines 1–24  
**Issue:** `lme4` is loaded on lines 1 and 12. The following packages are loaded but never called: `shiny`, `rvest`, `rpart`, `caret`, `randomForest`, `glmnet`, `xgboost`, `plotly`, `lubridate`, `data.table`, `gplots`, `ggridges`, `knitr`. Loading unnecessary packages causes namespace conflicts (e.g. `dplyr::select` vs `MASS::select`) and inflates session load time.  
**Fix:** Remove duplicate and unused `library()` calls. Add `dplyr::` namespace qualifier on `select()` and `filter()` calls if ambiguity remains.

---

### M11 — `=` used for object assignment

**File:** `ANALYSIS.R` lines 26, 38  
**Issue:** `dat1 = read.csv(...)` and `full_dat=read.csv(...)` use `=` for assignment. `.github/copilot-instructions.md` mandates `<-`.  
**Fix:** Replace all `=` assignments with `<-`.

---

### M12 — `full.dat` uses dot separator instead of snake_case

**File:** `ANALYSIS.R` line 34  
**Issue:** `.github/copilot-instructions.md` mandates snake_case. `full.dat` also lacks the `_df` suffix required for dataframes.  
**Fix:** Rename to `full_dat_df` (or `full_dat` if you prefer to reserve `_df` for intermediate objects).

---

### M13 — `author:` field is blank in Rmd YAML

**File:** `celegans_analysis.Rmd` line 3  
**Issue:** `author: ""` produces a rendered document with no attribution. This field must be populated before archiving.  
**Fix:** Add author name(s) to the YAML header.

---

## 🟡 Minor issues

### m1 — No `sessioninfo::session_info()` saved

**Files:** `ANALYSIS.R`, `celegans_analysis.Rmd`  
**Issue:** `.github/copilot-instructions.md` requires saving `sessioninfo::session_info()` to the output directory at the end of each top-level script.  
**Fix:** Add `sessioninfo::session_info() |> saveRDS(here::here("outputs", "session_info.rds"))` at the end of each script.

---

### m2 — No `renv.lock` present

**Repository root**  
**Issue:** There is no `renv.lock` to pin package versions. Any user restoring the environment will get whatever CRAN version is current, potentially breaking the analysis.  
**Fix:** Run `renv::init()` followed by `renv::snapshot()` and commit the resulting `renv.lock`.

---

### m3 — Chunk label `data-generation` misleads readers

**File:** `celegans_analysis.Rmd` line 25  
**Issue:** Once the simulation is replaced with real data import (see B4), rename the chunk label to `data-import` to accurately describe what it does.

---

### m4 — `geom_jitter()` without `alpha` makes overlapping points hard to read

**File:** `celegans_analysis.Rmd` line 122  
**Issue:** With 30 points per group and no transparency, overlapping jitter points obscure the actual distribution. `.github/copilot-instructions.md` figure guidance discourages obscuring raw data.  
**Fix:** Add `alpha = 0.5` to the `geom_jitter()` layer.

---

### m5 — `old_code.R` uses `MODEL_FINAL_THING` all-caps naming

**File:** `old_code.R` line 48  
**Issue:** Violates snake_case naming convention. A comment in the file itself (`# inconsistent naming chaos`) acknowledges this.  
**Fix:** Rename to `model_final` or remove the file from the archive.

---

### m6 — `ggsave()` writes to absolute path outside the repository

**File:** `ANALYSIS.R` line 79  
**Issue:** `ggsave(path = "~/Library/CloudStorage/…")` writes outside the repository tree. `.github/copilot-instructions.md` requires outputs to resolve inside the repository.  
**Fix:** Replace with `ggsave(here::here("outputs", "final_plot.jpg"), ...)` or similar.

---

## Recommended fix order

1. **Before any other work:** resolve data quality issues B7–B10 and M6–M9 by reviewing and correcting the raw CSV, then write a `01_clean.R` script that reproducibly produces the final dataset.
2. Fix B1–B6 in `ANALYSIS.R` (paths, missing files, typos, pipe style, read/write functions).
3. Fix B4 in `celegans_analysis.Rmd` (replace simulated data with real import).
4. Fix M1–M5 and M10–M13 in the analysis scripts.
5. Fix minor issues m1–m6.
6. Run `renv::init()` + `renv::snapshot()` to produce `renv.lock`.
7. Delete or clearly label `old_code.R` as non-executable archive material.
