"""
Scrape a public, static HTML table and save it to CSV.
Default target: Wikipedia table (static HTML, easy to parse).

Expected output: demo/data/scraped.csv
"""

from __future__ import annotations

import pathlib
import pandas as pd
import requests

URL = "https://en.wikipedia.org/wiki/List_of_countries_by_GDP_(nominal)"
OUT_PATH = pathlib.Path(__file__).resolve().parents[1] / "data" / "scraped.csv"


def main() -> None:
    # TODO: download HTML, parse the first table, clean column names, save CSV.
    # Hint: pd.read_html(URL) returns a list of tables.
    pass


if __name__ == "__main__":
    main()
