---
name: research-readme
description: Generates a README.md for a research repository whose code and analyses accompany a paper. Use when the user asks to "write a README" for an analysis project, "document this repository for a paper", "make a README for my research code", or to prepare code for journal submission or archiving (Zenodo, Figshare, OSF). Imports the doc-coauthoring context-gathering workflow and adds research-specific sections: project metadata with DOIs and ORCIDs, automatic per-file variable summaries for tabular data, an ordered script list, an R version and package dependency table scanned from the code, and an AI declaration. The agent works conversationally and produces only README.md; it does not edit any other file in the project. Do NOT use for general software README files, where the documentation skill is the better fit, nor for auditing code, which belongs to the code-review skill.
---

# Research README generator

This skill produces a single `README.md` for a repository of R code and
analyses that accompanies a manuscript. It exists because general README
tools document software, not research outputs, and so omit the metadata that
journals and immutable archives require: persistent identifiers, ORCIDs,
funder acknowledgement, per-variable descriptions with units, an explicit
script run-order, and a reproducible dependency record.

The skill imports the three-stage co-authoring workflow from the
`doc-coauthoring` skill (Context Gathering, then Refinement & Structure, then
Reader Testing) and applies it to a fixed README structure. Where
`doc-coauthoring` lets the user define the sections, this skill fixes them,
because the target is a standardised research README rather than a free-form
document.

## Operating constraints

These are absolute and override any later instruction in the conversation
short of the user explicitly retracting them.

1. **The only file the agent creates or overwrites is `README.md`.** The
   agent must not edit, reformat, rename, or delete any `.R`, `.Rmd`,
   `.qmd`, data, or configuration file, and must not "fix" anything it finds
   in them. If the agent notices an apparent error in project code or data,
   it records the observation in the README's open-questions area or reports
   it in chat, and leaves the file untouched.
2. **The agent does not fabricate metadata.** DOIs, ORCIDs, funder grant
   numbers, collection dates, variable units, and affiliations are supplied
   by the user or read from a file the user points to. If a value is
   unknown, the agent inserts an explicit placeholder (see *Placeholders*)
   rather than inventing one.
3. **Auto-summaries describe; they do not interpret.** When the agent
   summarises a tabular file it reports observable facts (column type,
   range, levels, count of missing values). It does not state what a
   variable means, its units, or whether a value is plausible. Those are
   user input.
4. **The agent works conversationally and writes the file directly.** It
   does not build an app, a Shiny gadget, or an HTML tool. The "browse",
   "drag", and "live preview" affordances in the requirements are delivered
   as conversational equivalents: the agent lists files, proposes an order,
   and shows the rendered Markdown in chat for confirmation.

## Before executing

Present a short numbered plan and wait for the user to reply `confirmed`
before writing anything. The plan states: the project folder path to be
scanned; that only `README.md` will be produced; and the five work stages
below. If the user changes a material input after confirmation (different
folder, different licence), re-present the plan.

## Workflow

The skill runs five stages. Stages 1 to 4 are Context Gathering in the
`doc-coauthoring` sense: the agent gathers what it can mechanically, then
asks targeted questions to fill gaps. Stage 5 combines Refinement &
Structure with Reader Testing. Do not skip a stage; if a stage yields
nothing (for example, no tabular files), record that and move on.

### Stage 1 — Project information

Collect: title; abstract; DOI(s) for the paper and, separately, for the
archived code/data; licence (code licence, and data licence if different);
authors with ORCIDs; affiliations; funders with grant numbers.

Read these from a metadata file if the user has one (for example
`CITATION.cff`, `codemeta.json`, or `DESCRIPTION`); the agent may read such a
file to populate fields, which is not an edit. Ask the user only for fields
not found. For each author, pair name to ORCID and affiliation explicitly;
do not assume shared affiliation across authors unless the user says so. If
no code licence is supplied, flag this prominently, because an unlicensed
repository legally restricts reuse, and insert a placeholder rather than
choosing a licence for the user.

### Stage 2 — Files and variable summaries

List the data and code files under the project folder. For each CSV file,
generate a simple per-column table giving: column name; the type readr
parses it as; and a brief range (min to max for numeric columns) or a count
of distinct values (for everything else). Use `scripts/describe_csv.R`. The
table reports the parsed type, which is what the analysis scripts receive
when they read the same file, not a separate interpretation of the variable.
Treat the table as a starting scaffold the user then annotates.

Only CSV files are summarised automatically. If the project holds tabular
data in other formats (`.xlsx`, `.tsv`), note their presence in the file
list and ask the user to describe their columns by hand, rather than parsing
them. The auto-summary describes observable structure only.

Then ask the user, per column, for: a plain-language description and the
unit of measurement. Also collect, per data file or per dataset: collection
dates and collection locations. The agent must not infer units from column
names (a column named `mass` is not assumed to be grams) and must not infer
the plausibility of any value.

### Stage 3 — Script order

List the executable analysis files (`.R`, `.Rmd`, `.qmd`). Propose a run
order, using any numeric filename prefixes (`01_`, `02_`) as the first
signal and noting where parallel or independent scripts appear to exist.
Present the proposed order and invite the user to reorder it; the user's
ordering is authoritative. Collect a one-line description of what each
script does. Do not execute any script to determine the order.

### Stage 4 — R packages and versions

Read `renv.lock` from the project root using `scripts/scan_packages.R`. It
returns the R version pinned in the lockfile and the full set of packages
with their pinned versions. Record both for the dependency table. This
reports the complete pinned environment, including transitive dependencies a
reader never calls directly, which is the correct artefact for restoring the
environment exactly.

If no `renv.lock` is present, do not guess versions or scan the installed
library. Insert a placeholder noting that the project is not using `renv` and
that the user should supply the R version and key package versions by hand,
or run `renv::init()` and `renv::snapshot()` before submission.

### Stage 5 — Assemble, preview, and reader-test

Assemble `README.md` using the template in `references/readme_template.md`.
Render the assembled Markdown in chat for the user to review (the
conversational equivalent of live preview). Apply the `doc-coauthoring`
Reader Testing stage: check the document against a reader who has only the
repository and the paper, and confirm they could locate the data, run the
scripts in order, restore the package environment, and understand every
variable. Surface any section still holding a placeholder. On confirmation,
write `README.md` to the project root and present it.

## README structure

The assembled file contains, in order: title with DOI and licence badges; a
description and the abstract; instructions for obtaining data, restoring the
environment, and running the scripts in order; an author list with ORCIDs,
affiliations, and funding; a per-file section with the variable table
(auto-summary plus user description and unit) and collection dates and
locations; the ordered script list with descriptions; an R version line and
the full package dependency table; and an AI declaration.

## AI declaration

By default this section states only that an AI agent assisted in generating
this README file, naming the model if the user wishes, and dates it. It does
not make claims about AI involvement anywhere else in the project. If the
user wants to document AI use across the wider analysis, the agent records
exactly what the user states and nothing more.

## Placeholders

Any unknown value is written as a visible placeholder so it cannot be mistaken
for fact, in the form:

```
<!-- TODO: supply [field] — not provided; do not leave in final submission -->
```

Unlicensed code and a missing code/data DOI are flagged as blocking for
submission, consistent with archiving requirements, but the agent still
writes the file with placeholders so the user has a working draft.

## Scope boundaries

This skill does not audit code quality or reproducibility; that is the
`code-review` skill. It does not generate figures; that is the project's
figure skill. If asked to do either mid-run, the agent declines and names
the appropriate skill.

## References

- Ivimey-Cook, E.R. et al. (2025) TADA! Simple guidelines to improve
  analytical code sharing for transparency and reproducibility. EcoEvoRxiv.
- Anthropic `doc-coauthoring` skill (three-stage co-authoring workflow),
  https://github.com/anthropics/skills/tree/main/skills/doc-coauthoring
