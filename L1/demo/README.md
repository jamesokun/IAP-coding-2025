# Codex Demo: Econ PhD Use Cases (3 segments)

This folder contains a ready-to-run, 3-part demonstration.

## Segment 1: Simple model -> DGP code
Goal: start from a canonical Solow growth model and have Codex implement the DGP.

- Model: y_t = A_t * k_t^alpha; k_{t+1} = (1 - delta) k_t + s y_t; log A has shocks
- Output: simulated panel data + a quick plot of moments
- File: `segment1/dgp_template.py`

Suggested prompt to Codex:
"Implement the DGP described in the header of dgp_template.py. Generate N economies over T periods, save to CSV, and plot mean(k_t) and mean(y_t) over time. Keep it simple and reproducible."

## Segment 2: Messy code cleanup
Goal: show how Codex can refactor messy research code.

- File: `segment2/messy_analysis.py`
- The script is intentionally messy, duplicated, and hard to read.

Suggested prompt to Codex:
"Refactor messy_analysis.py: remove duplication, add functions, make parameters explicit, and add minimal checks. Keep behavior the same."

## Segment 3: Web scraping
Goal: show Codex writing a scraper for a public, static table.

- File: `segment3/scrape_demo.py`
- Default target is a Wikipedia table. You can swap the URL.

Suggested prompt to Codex:
"Complete scrape_demo.py to download the table, clean column names, and save a CSV to demo/data/. Include basic error handling."

## Quick run commands
- Segment 1: `python demo/segment1/dgp_template.py`
- Segment 2: `python demo/segment2/messy_analysis.py`
- Segment 3: `python demo/segment3/scrape_demo.py`
