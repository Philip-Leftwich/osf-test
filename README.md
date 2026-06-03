# *C. elegans* Reproductive Output: Strain × Diet Analysis

## Overview

This repository contains data and analysis code examining how **genetic strain** and **dietary regimen** affect total reproductive output in *Caenorhabditis elegans*. The pre-registered model specification is:

```
total_offspring ~ strain * diet + (1 | block)
```

where `total_offspring` is a non-negative integer count, `strain` and `diet` are fixed effects (with interaction), and `block` is a random effect accounting for experimental batch.

> **Note:** A code review of `ANALYSIS.R` has been conducted and documented in [`review.md`](review.md). Several critical issues were identified. Readers and re-users should consult that document before relying on outputs from `ANALYSIS.R`.

---

## Repository Contents

| File | Description |
|------|-------------|
| `ANALYSIS.R` | Primary analysis script (see `review.md` for known issues) |
| `celegans_analysis.Rmd` | R Markdown document with a cleaner, more reproducible version of the analysis |
| `celegans_analysis.html` | Rendered HTML output from the R Markdown document |
| `celegans_repro_raw.csv` | Raw data as collected; uses `9999` as a "not recorded" sentinel |
| `celegans_repro_final.csv` | Processed data after exclusions and sentinel removal |
| `review.md` | 4Rs code review of `ANALYSIS.R` |
| `ExtractedFigure1.png` | Figure 1 extracted from the original publication |
| `final.jpeg` / `finalplot.jpeg` | Output figures from the analysis |
| `Flowchart.jpg` | Experimental design flowchart |
| `4Rs.jpg` | Diagram of the 4Rs reproducibility framework |
| `old_code.R` | Earlier version of analysis script (archived) |

---

## Data

### Raw data (`celegans_repro_raw.csv`)

- **`worm_id`** — unique individual identifier  
- **`block`** — experimental block (random effect; integer 1–5)  
- **`strain`** — genetic strain (`empty_vector` or `daf`)  
- **`diet`** — dietary treatment (`AL` = *ad libitum*; `EODF` = every-other-day feeding)  
- **`total_offspring`** — count of total offspring produced  

> ⚠️ The raw file encodes missing / not-recorded values as **`9999`**. These must be converted to `NA` before any analysis. This is not handled in `ANALYSIS.R` (see `review.md`).

---

## Pre-registered Model

The confirmatory model is a **generalised linear mixed model** with a negative-binomial or Poisson family, appropriate for overdispersed count data:

```r
library(lme4)
m_confirmatory <- glmer.nb(
  total_offspring ~ strain * diet + (1 | block),
  data = dat
)
```

`ANALYSIS.R` fits this using `lmer()` (Gaussian), which is a deviation from the pre-registration. The R Markdown document (`celegans_analysis.Rmd`) uses the correct model family.

---

## How to Run

1. Clone or download this repository.
2. Open `celegans_analysis.Rmd` in RStudio or Positron (preferred over `ANALYSIS.R`).
3. Install required packages if needed:

```r
install.packages(c("tidyverse", "lme4", "lmerTest", "emmeans", "DHARMa"))
```

4. Knit the document or run chunks interactively.

> The R Markdown script uses relative paths and a reproducible seed (`set.seed(42)`). No manual path editing should be required.

---

## Known Issues

See [`review.md`](review.md) for a full 4Rs (Reported, Run, Reliable, Reproducible) code review. Critical issues include:

- `ANALYSIS.R` will not run on any machine other than the original author's (hard-coded absolute paths)
- Two typos (`libray`) cause the script to halt before any analysis executes
- The `9999` sentinel is never removed from the data
- An operator-precedence bug silently retains `NA` diet rows for one strain
- The wrong model family (Gaussian instead of count) is used

---

## Reproducibility Summary

| Item | Status |
|------|--------|
| Random seed set | ✅ `celegans_analysis.Rmd` (`set.seed(42)`) / ❌ `ANALYSIS.R` |
| Relative file paths | ✅ `celegans_analysis.Rmd` / ❌ `ANALYSIS.R` |
| 9999 sentinel handled | ✅ `celegans_repro_final.csv` present / ❌ `ANALYSIS.R` |
| Correct model family | ✅ `celegans_analysis.Rmd` / ❌ `ANALYSIS.R` |
| Session info recorded | ❌ Neither script — **NEEDS HUMAN CHECK** |
| Raw data deposited | ✅ `celegans_repro_raw.csv` present |

---

## Contact

For questions about the experimental design or data, contact the repository owner.  
For questions about the code review, refer to [`review.md`](review.md).
