# Code Review: ANALYSIS.R
**Framework:** 4Rs (Reported, Run, Reliable, Reproducible)  
**Script:** `ANALYSIS.R`  
**Pre-registered model:** `total_offspring ~ strain * diet + (1 | block)`, negative-binomial or Poisson GLMM  
**Reviewer date:** 2026-06-03

---

## 1. Reported

Issues with what is declared or disclosed in the script.

| Line(s) | Issue | Severity | Fix |
|---------|-------|----------|-----|
| 1–24 | Thirteen packages are loaded but never used: `rvest`, `shiny`, `rpart`, `caret`, `randomForest`, `glmnet`, `xgboost`, `plotly`, `gplots`, `ggridges`, `lubridate`, `stringr`, `knitr`. Obscures true dependencies and introduces version-conflict risk. | **Medium** | Remove all unused `library()` calls. |
| 1, 16 | `lme4` loaded twice. | **Medium** | Remove the duplicate on line 16. |
| 3, 22 | `tidyverse` loaded twice (lines 3 and 22). | **Medium** | Remove the duplicate on line 22. |
| 3–5 | `ggplot2`, `dplyr`, and `tidyr` loaded individually after `tidyverse` already attaches them. | **Low** | Remove lines 4–6; they are redundant. |
| 34 | `filter(worm_id != 5)` silently drops a worm with no inline comment justifying the exclusion. Unreported exclusion criteria violate reporting standards. | **High** | Add a comment citing the pre-registration exclusion rule, e.g. `# excluded per pre-reg: worm_id 5 had incomplete setup`. |
| — | No `sessionInfo()` or lockfile. Package versions are unspecified and unreported. | **High** | Add `sessionInfo()` at the end of the script, or commit an `renv.lock`. |

---

## 2. Run

Issues that prevent or impair the script from executing.

| Line(s) | Issue | Severity | Fix |
|---------|-------|----------|-----|
| 22–23 | `libray(tidyverse)` and `libray(hablar)` are misspelled. The script will **halt** at this point before any analysis runs. | **Critical** | Change both to `library()`. |
| 25 | Absolute, machine-specific path (`~/Library/CloudStorage/OneDrive-UniversityofGlasgow/…`). The script errors on any other machine. | **Critical** | Replace with a relative path or `here::here("celegans_raw.csv")`. |
| 38–40 | `full.dat` is written to disk and immediately re-read as `full_dat`. The write path is the same hard-coded personal path. If the path is unavailable, the script halts before the models run. The round-trip also silently renames `"total offspring"` (space) to `"total.offspring"` (dot), creating a name mismatch. | **High** | Remove the `write.csv`/`read.csv` round-trip; work with `full.dat` directly, renamed to `full_dat`. |
| 34 | `pivot_longer(dat1, cols = 3:5, …)` uses positional column indexing. If CSV column order changes, wrong columns are pivoted silently. | **High** | Use named columns: `cols = c(col_a, col_b, col_c)`. |
| 57–60 | `anova(m1a, m1b, m1c)` passes two `lmer` objects and one `lm` object. This will error or produce a meaningless table; `lme4` model comparison requires all models to be the same class. | **High** | Compare mixed models only: `anova(m1a, m1b)`. Compare `m1c` separately via `AIC()`/`BIC()` if exploratory. |
| 77 | `ggsave()` writes to the same hard-coded personal path. Fails on any other machine. | **Critical** | Replace with a relative path, e.g. `ggsave("final2.jpg", dpi = 300)`. |

---

## 3. Reliable

Issues with statistical validity and fidelity to the pre-registration.

| Line(s) | Issue | Severity | Fix |
|---------|-------|----------|-----|
| 43–55 | **Pre-registration violation — wrong model family.** Total offspring is a non-negative integer count that is typically overdispersed. Both `m1a` and `m1b` use `lmer()` (Gaussian), misspecifying the response distribution and producing invalid inference (e.g. negative fitted values, wrong SEs). | **Critical** | Use `glmer.nb(total_offspring ~ strain * diet + (1\|block), data = full_dat)` or `glmer(..., family = poisson)` with overdispersion checks. |
| 43–48 | `m1a` omits the `strain * diet` interaction mandated by the pre-registration and is not labelled as exploratory. The distinction between confirmatory (`m1b`) and exploratory (`m1a`) is undocumented. | **High** | Add comments marking `m1b` as the confirmatory pre-registered model and `m1a` as exploratory. |
| 46 | `filter(strain == "daf" \| strain == "empty_vector" & !is.na(diet))` — operator precedence means `&` binds before `\|`, so NA-diet rows are **retained** for `"daf"` strain. Almost certainly unintentional and inflates `"daf"` sample size. | **Critical** | `filter((strain == "daf" \| strain == "empty_vector") & !is.na(diet))` |
| — | **9999 sentinel not handled.** Raw data use `9999` as "not recorded". No line converts or removes these values. They will be treated as valid large counts, massively distorting all model estimates. | **Critical** | Add after `read.csv`: `mutate(across(where(is.numeric), ~na_if(., 9999)))` |
| 43–55 | No residual diagnostics performed after fitting. With Gaussian `lmer` on count data, assumption violations will be severe and undetected. | **High** | Add `DHARMa::simulateResiduals(m1b, plot = TRUE)` after model fitting. |
| 68–75 | `geom_smooth(method = "lm")` overlays a Gaussian linear smoother on count data modelled with a GLMM. Misleading. | **Medium** | Remove or replace with model-predicted marginal means via `emmeans`. |

---

## 4. Reproducible

Issues that prevent others from independently reproducing the results.

| Line(s) | Issue | Severity | Fix |
|---------|-------|----------|-----|
| 25, 38, 77 | Three hard-coded personal absolute paths. Script cannot be run by any other researcher without manual editing. | **Critical** | Use `here::here()` throughout; store raw data in the project directory. |
| — | No `set.seed()` anywhere. `mean_cl_boot` (lines 71–72) uses bootstrap resampling, so plot confidence intervals are not exactly reproducible across runs. | **Medium** | Add `set.seed(<integer>)` before the `ggplot` block. |
| 38–40 | The write→read round-trip means the object entering the modelling block (`full_dat`) is a freshly parsed CSV, not the in-memory wrangled object. The data pipeline is broken across a file I/O boundary. | **High** | Remove round-trip; use the in-memory object directly. |
| — | No `renv.lock`, `DESCRIPTION`, or `sessionInfo()` call. Package versions are undocumented. `lme4` results (REML vs ML defaults, optimizer) can differ across versions. | **High** | Add `sessionInfo()` at the script's end, or initialise `renv`. |
| — | **NEEDS HUMAN CHECK:** Whether `celegans_raw.csv` is publicly deposited (e.g. on OSF) alongside the script cannot be verified by code inspection alone. |
| — | **NEEDS HUMAN CHECK:** Whether `9999` sentinel values are actually present in the raw CSV, and how many rows they affect, requires inspection of the data file. |
| — | **NEEDS HUMAN CHECK:** Whether the corrected script produces numerically identical results to those reported in the manuscript requires running it against the original raw data. |

---

## Summary of Critical Issues

| # | Location | Issue |
|---|----------|-------|
| 1 | Lines 22–23 | `libray()` typos halt execution before any analysis runs |
| 2 | Lines 25, 38, 77 | Hard-coded personal paths prevent execution on any other machine |
| 3 | Lines 43–55 | Wrong model family (`lmer`/Gaussian) for count data — pre-registration violation |
| 4 | Line 46 | Operator precedence bug retains NA-diet rows for `"daf"` strain |
| 5 | Entire script | `9999` sentinel values never removed — will corrupt all model estimates |
