# CLAUDE.md

Personal academic website of Georgiy (Gosha) Syunyaev, live at gsyunyaev.com. Read README.md first: it documents the layout, the bib fields the site understands, how entries are sorted into sections, rendering, and deployment.

## Working rules

- Sources are `index.qmd`, `404.qmd`, `_quarto.yml`, `styles.css`, `_includes/head.html`, `R/pubs.R`, `_bibliography/papers.bib`, and `_data/coauthors.yml`. `docs/` is rendered output. Never edit it by hand, regenerate it with `quarto render`, and commit it together with the sources, because GitHub Pages serves `docs/` from `master` and there is no build step on GitHub.
- Render before every commit, and verify the rendered page (grep `docs/index.html`, or screenshot it with headless Chrome) rather than trusting the render log.
- Everything under `assets/` is copied verbatim into `docs/`, and those URLs are public and linked from outside: slide decks, PDFs, and the pre-analysis plan at `assets/html/pap`. Do not rename or move those files.
- The publication lists are generated from the bib file. Change them by editing the bib, not the HTML or the R code, unless a new field or behaviour is needed.
- Quarto uses the first R on PATH, the CRAN framework build (`quarto check knitr` shows it). The generator needs the R packages `RefManageR` and `yaml`.
- A `quarto preview` server may be running from VS Code. It re-renders on file changes and can make a concurrent `quarto render` fail while moving `index.html` into `docs/`. Wait a few seconds and render again.
- Commit messages: one lowercase subject line in the owner's plain wording, no body. Pushing to `master` deploys. A repository ruleset prints a "Bypassed rule violations" notice on direct pushes, which is expected.
- Fonts are self-hosted under `assets/fonts/`: IBM Plex Sans for the page, IBM Plex Mono for code blocks only. Do not add Google Fonts or other third-party requests.
- No research data lives in this repository. `assets/pdf/` holds published and working papers only.
