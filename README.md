# C. elegans Reproduction Analysis

This repository contains data and R code for a mixed-model analysis of reproduction in *Caenorhabditis elegans* across two genetic strains (`empty_vector`, `daf`) and two dietary treatments (Ad Libitum `AL`; Every-Other-Day Feeding `EODF`).

---

## Repository structure

| File | Description |
|------|-------------|
| `celegans_analysis.Rmd` | **Primary analysis script** — reproducible R Markdown document covering data simulation, modelling, diagnostics, and visualisation |
| `celegans_analysis.html` | Rendered HTML output of the primary analysis |
| `celegans_repro_raw.csv` | Raw data: worm ID, block, strain, diet, and total offspring count |
| `celegans_repro_final.csv` | Processed data used in the final analysis |
| `ANALYSIS.R` | Intermediate R script (see [Code Review](#code-review) notes) |
| `old_code.R` | Earlier draft R script (see [Code Review](#code-review) notes) |
| `4Rs.jpg`, `Flowchart.jpg`, `ExtractedFigure1.png`, `final.jpeg`, `finalplot.jpeg` | Supporting figures |

---

## Data

Both CSV files (`celegans_repro_raw.csv`, `celegans_repro_final.csv`) share the same column structure:

| Column | Type | Description |
|--------|------|-------------|
| `worm_id` | integer | Unique worm identifier |
| `B` | integer | Experimental block (1–5) |
| `strain` | character | Genetic strain: `daf` or `empty_vector` |
| `diet` | character | Dietary treatment: `AL` (ad libitum) or `EODF` (every-other-day feeding) |
| `TO` | integer | Total offspring count |

---

## Analysis overview

The primary analysis (`celegans_analysis.Rmd`) follows these steps:

1. **Data simulation** — a negative-binomial dataset is generated with `set.seed(42)` to ensure full reproducibility, mimicking the structure of the real experiment (4 strain × diet combinations × 5 blocks × 6 worms per cell).
2. **Descriptive summary** — group means and standard deviations.
3. **Model fitting** — three generalised linear mixed models (GLMMs) with a negative-binomial response are compared:
   - Null model (`~ 1 + (1|block)`)
   - Additive model (`~ strain + diet + (1|block)`)
   - Full interaction model (`~ strain * diet + (1|block)`)
4. **Model comparison** — AIC and likelihood-ratio test (`anova()`).
5. **Diagnostics** — simulated residuals via `DHARMa`.
6. **Post-hoc contrasts** — pairwise comparisons with `emmeans`.
7. **Visualisation** — jitter + boxplot coloured by strain.

---

## Requirements

R packages used in the primary analysis:

```r
install.packages(c("tidyverse", "lme4", "lmerTest", "emmeans", "DHARMa"))

# ThemePark is on GitHub:
# remotes::install_github("matthewbjane/ThemePark")
```

---

## Running the analysis

Open `celegans_analysis.Rmd` in RStudio and click **Knit**, or run from the R console:

```r
rmarkdown::render("celegans_analysis.Rmd")
```

---

## Code Review

A review of the three R scripts in this repository is provided below.

### `celegans_analysis.Rmd` ✅ Recommended script

This is the cleanest, most reproducible version of the analysis. Strengths:

- Uses `set.seed()` for reproducibility.
- Applies an appropriate statistical model: a negative-binomial GLMM via `glmer.nb()`, which correctly handles overdispersed count data.
- Structured as a self-contained R Markdown document.
- Model comparison is carried out with AIC and a likelihood-ratio test.
- Residual diagnostics use `DHARMa::simulateResiduals()`, which is well-suited to GLMMs.

Suggestions for improvement:

- **Plot**: `geom_jitter()` and `geom_boxplot()` both inherit `colour = strain`, causing the box outlines to be coloured, which can be harder to read. Consider mapping `fill = strain` to the boxplot and leaving jittered points uncoloured, or use `geom_violin()`.
- **Plot labels**: axis labels and a plot title are missing.
- **Author field**: the YAML header has a blank `author:` field — worth populating.
- **`ThemePark`**: a novelty ggplot theme that is not on CRAN, adding an extra install step; standard `theme_bw()` or `theme_minimal()` would be more portable.

---

### `ANALYSIS.R` ⚠️ Intermediate script

This script represents an earlier, less polished stage of the workflow.

Issues:

- **Hardcoded absolute paths** specific to one machine (`~/Library/CloudStorage/OneDrive-UniversityofGlasgow/...`). These will fail on any other system. Use relative paths or a project-relative helper such as `here::here()`.
- **Redundant and unused packages**: `shiny`, `rpart`, `caret`, `randomForest`, `glmnet`, `rvest`, `lubridate`, `ggridges`, `gplots`, `data.table`, and `plotly` are loaded but never used. Remove them.
- **Typos** on lines 23–24: `libray(tidyverse)` and `libray(hablar)` — `library` is misspelled; these calls will throw an error.
- **Model type mismatch**: `anova(m1a, m1b, m1c)` compares two `lmer` models and one `lm` model together. `anova()` cannot validly perform a likelihood-ratio test across different model classes; this comparison should be split or restricted to models of the same class.
- **Linear model for count data**: `m1c` uses `lm()` on total offspring counts. Count data are non-negative integers and often overdispersed; a Poisson or negative-binomial GLMM is more appropriate (as used in the Rmd).
- **No comments** explaining analysis decisions.

---

### `old_code.R` ❌ Early draft — not recommended

This file contains the same core issues as `ANALYSIS.R` but in a denser, less readable form.

Additional issues:

- **Duplicate `library(lme4)`** call (lines 1 and 12).
- **Inconsistent naming conventions**: objects use `snake_case`, `camelCase`, and `SCREAMING_CAPS` (`MODEL_FINAL_THING`) within the same script.
- **Inconsistent whitespace and indentation** throughout.
- **Mixed methodology**: a `t.test()` is run mid-script on the same data used for mixed models — the two approaches are not reconciled.
- **`# back to original data for no reason`**: a self-referential comment indicating code that was not cleaned up.
- A comment notes "inconsistent naming chaos", suggesting the script was never finalised.

This file should be treated as historical context only and not used for analysis.
