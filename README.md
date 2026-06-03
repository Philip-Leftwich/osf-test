# <!-- TODO: full title of the paper/project -->

<!-- TODO: add badges, e.g. OSF DOI, licence, renv status -->
<!-- [![OSF DOI](https://img.shields.io/badge/OSF-10.17605%2FOSF.IO%2FXXXXX-blue)](https://doi.org/10.17605/OSF.IO/XXXXX) -->

## Description

<!-- TODO: 2–4 sentence plain-language description of the research question,
     organism, and key outcome. -->

This repository contains the raw data, cleaning scripts, statistical analysis,
and figures for a study of reproductive output in *Caenorhabditis elegans*
across genetic strains and dietary treatments.

## Abstract

<!-- TODO: paste the published or pre-registered abstract here. -->

## Contents

```
.
├── data/
│   ├── raw/                  # Immutable raw data — never overwritten
│   │   └── celegans_repro_raw.csv
│   └── derived/              # Programmatically generated; safe to delete and re-run
│       └── celegans_repro_final.csv
├── output/                   # Figures, model summaries, session info
├── ANALYSIS.R                # Main analysis script (run this)
├── celegans_analysis.Rmd     # Supplementary or extended analysis (Rmd)
└── old_code.R                # Archived draft — not part of the analysis pipeline
```

## Data files

### `data/raw/celegans_repro_raw.csv`

295 rows × 5 columns.

| Column | Type | Range / Values | Description | Unit |
|--------|------|----------------|-------------|------|
| `worm_id` | integer | 1 – 506 | Individual worm identifier | — |
| `B` | integer | 1 – 6 | Block (experimental replicate) | <!-- TODO: confirm unit --> |
| `strain` | character | 3 unique values | Genetic strain | — |
| `diet` | character | 4 unique values | Dietary treatment | — |
| `TO` | numeric | −46 – 9999 ⚠️ | Total offspring produced | count |

> **Note:** column names in the CSV (`B`, `TO`) differ from the names used in
> the analysis scripts (`block`, `total_offspring`). This will need to be
> reconciled before the analysis can run — either rename the CSV columns or
> supply explicit `col_names` in `readr::read_csv()`.

### `data/derived/celegans_repro_final.csv`

506 rows × 5 columns. Column structure identical to the raw file; values from `describe_csv()`.

| Column | Type | Range / Values | Description | Unit |
|--------|------|----------------|-------------|------|
| `worm_id` | numeric | 1 – 506 | Individual worm identifier | — |
| `B` | numeric | 1 – 6 | Block (experimental replicate) | <!-- TODO: confirm unit --> |
| `strain` | character | 3 unique values | Genetic strain | — |
| `diet` | character | 4 unique values | Dietary treatment | — |
| `TO` | numeric | −46 – 9999 ⚠️ | Total offspring produced | count |

> **⚠️ Data integrity flag:** `TO` has a minimum of −46. A negative offspring count is biologically implausible and must be investigated before analysis.
