# gsyunyaev.com

Personal academic website of Georgiy Syunyaev. A single-page Quarto site: header with headshot and links, a short bio, and publication lists generated from a BibTeX file. Rendered output is committed to `docs/`, which GitHub Pages serves at [gsyunyaev.com](https://gsyunyaev.com). There is no build step on GitHub: what you render locally is what goes live when you push.

## Repository layout

| Path | What it is |
| --- | --- |
| `index.qmd` | The home page: header block, bio, and the R chunks that print the publication sections. |
| `404.qmd` | The page shown for unknown URLs. |
| `_quarto.yml` | Project configuration: pages to render, output directory, files copied through, analytics ID. |
| `styles.css` | The whole stylesheet. The colour palette is the block of variables at the top. |
| `_includes/head.html` | Two small scripts: the `[Abstract]` and `[BibTeX]` toggles, and sizing of the headshot to the text block. |
| `_bibliography/papers.bib` | All publications, working papers, projects, and software. Edit this to change the lists. |
| `_data/coauthors.yml` | Coauthor homepages, keyed by last name. Names in the lists become links when they match. |
| `R/pubs.R` | Reads the bib file and prints the lists as HTML. Sourced by `index.qmd` at render time. |
| `assets/pdf/` | Paper PDFs linked from bib entries. |
| `assets/html/` | Slide decks and other standalone HTML linked from outside the site. Do not rename or move these, their URLs are public. |
| `assets/img/` | Favicon and headshot (`profile_pic.jpg` is the original, `profile_pic_web.jpg` the 400px copy the page uses). |
| `assets/fonts/` | Self-hosted Fira Sans and Fira Code (woff2, Latin and Latin Extended subsets) with their licences. |
| `cv/syunyaev_cv.pdf` | The CV linked from the header. |
| `CNAME`, `.nojekyll`, `robots.txt` | Copied into `docs/` on every render. `CNAME` binds the custom domain. |
| `docs/` | Rendered site. Never edit by hand, it is overwritten on every render. |

Directories starting with `_` are ignored by Quarto's renderer, which is why the bib file, the data file, and the head include live in such folders.

## Posting a paper

1. Add or edit an entry in `_bibliography/papers.bib`. See the field reference below.
2. If there is a PDF, drop it into `assets/pdf/` and set `pdf={filename.pdf}` in the entry.
3. Render the project (see Rendering below).
4. Commit the sources and `docs/`, then push to `master`. The site updates within a minute or two.

## Which section an entry lands in

| Section | Rule |
| --- | --- |
| Publications | `@article`, `@inproceedings`, `@incollection`, `@book`. Sorted newest year first, then bib-file order within a year. |
| Working Papers | `@unpublished` or `@misc` with `status={wp}`. Bib-file order. |
| Work in Progress | `@unpublished` or `@misc` with any other `status` (`design`, `implementation`, `analysis`, `manuscript`, and so on). Bib-file order. |
| Software | `@manual`. Bib-file order. |

For everything except publications, the order on the page is the order in the bib file, so move entries around in the file to reorder them.

## Bib fields the site understands

| Field | Effect |
| --- | --- |
| `title`, `author` | Shown in bold and as "(with A, B, and C)". Your own name is dropped from the list. An author literally named `others` with a number as first name renders as "and 24 others". TeX quotes and dashes (` `` '' -- --- `) are converted, braces are stripped. |
| `abstract` | Adds an `[Abstract]` toggle. |
| `note` | The stage or venue text for non-journal entries: "Working paper", "OSF Pre-Print", "Design", "Manuscript preparation", and for software your role. Ignored for journal articles and chapters. |
| `year`, `journal`, `volume`, `number`, `pages` | The venue line of an article: "2025. *Journal*, 14 (1): 231–239." |
| `booktitle`, `editor`, `publisher`, `pages` | The venue line of a chapter: "2015. In A and B (eds.), *Book*, Publisher, 167–186." |
| `html` or `url` | Where the title links. Use the publisher page for published work. |
| `doi` | Used for the title link if `html` and `url` are absent. Shown in the BibTeX block. |
| `preprint` | Adds `[Preprint]`. Also used for the title link if nothing above is set. |
| `pdf` | Adds `[PDF]`. A bare filename points into `assets/pdf/`, a full URL is used as is. |
| `supp`, `slides`, `poster` | Add `[Supplement]`, `[Slides]`, `[Poster]`, same filename rule as `pdf`. |
| `code` | Adds `[Code]`. |
| `pap` | Adds `[Pre-analysis plan]`. Several plans: `pap={Label\|URL; Label\|URL}` gives `[Pre-analysis plan: Label]` for each. Without labels they are numbered. |
| `media` | Adds a muted "[Media: NPR, BBC]" line under the entry. Format: `media={NPR\|URL; BBC\|URL}`. A bare URL is labelled with its host name. |
| `bibtex_show={true}` | Adds a `[BibTeX]` toggle showing the entry with the site-only fields removed. |
| `status` | Section assignment, see above. |
| `abbr`, `selected` | Ignored. Kept for compatibility with the old site. |

Order of the bracketed links is fixed: Abstract, Preprint, PDF, Supplement, Pre-analysis plan, Code, Slides, Poster, BibTeX.

## Other routine updates

- **CV**: replace `cv/syunyaev_cv.pdf`, keeping the filename, then render and push.
- **Bio, title block, header links**: edit `index.qmd`. The header is plain HTML at the top of the file, the bio is Markdown below it.
- **Headshot**: replace `assets/img/profile_pic.jpg`, then create the web copy with `sips -Z 400 assets/img/profile_pic.jpg --out assets/img/profile_pic_web.jpg`. The page sizes it to the height of the text block automatically.
- **Coauthor links**: add a block to `_data/coauthors.yml` keyed by last name, with the first-name spellings that appear in the bib and the URL. Existing entries show the format.
- **Theme**: edit the variables at the top of `styles.css`. The current palette is Gruvbox dark, and a Monokai Pro set is in the comment right below it. Everything else in the stylesheet uses these variables.
- **Fonts**: the text font is Fira Sans and the label font (header links, bracketed links, media line, code) is Fira Code with its ligatures turned off, both self-hosted from `assets/fonts/` and declared in the `@font-face` rules at the top of `styles.css`. To switch fonts, put new woff2 files in that folder, update the `@font-face` rules, and change the `--font-text` and `--font-mono` variables. The system font stack after them is the fallback.
- **Google Analytics**: the measurement ID is in `_quarto.yml`.

## Rendering

The site needs Quarto and R with the packages `RefManageR`, `yaml`, `knitr`, and `rmarkdown`. Install missing ones with `Rscript -e 'install.packages(c("RefManageR", "yaml"))'`.

In VS Code with the Quarto extension:

- **Quarto: Render Project** (Command Palette, Cmd+Shift+P) renders every page into `docs/`. Use this before committing, and always after editing the bib file.
- **Quarto: Preview** (Cmd+Shift+K, or the preview button) opens a live preview that re-renders on save. It also writes into `docs/`. It does not watch the bib file and reuses cached R output at startup, so after a bib edit either run Render Project or save `index.qmd` once while the preview is running.

From a terminal in the repository: `quarto render` (full render) or `quarto preview` (live preview).

## Deploying

GitHub Pages is set to serve the `docs/` folder of the `master` branch. Pushing to `master` is the deployment. Progress and errors show under the repository's Actions tab as "pages build and deployment", and the live site is at [gsyunyaev.com](https://gsyunyaev.com). Rolling back is `git revert` of the offending commit and another push.

The `gh-pages` branch and the GitHub Actions workflow belonged to the previous Jekyll site (al-folio theme, retired September 2026) and are no longer used.

## Troubleshooting

- **"there is no package called 'RefManageR'"**: the package is missing from the R that Quarto uses. `quarto check knitr` prints which R that is. Install the package there.
- **The publication list did not change after editing the bib file**: you were looking at a preview. Run Render Project.
- **An entry is in the wrong section**: check its entry type and `status` field against the table above.
- **A coauthor is not linked**: the first name in the bib must appear in that person's `firstname` list in `_data/coauthors.yml`.
- **An old asset URL broke**: everything under `assets/` is copied verbatim, so check that the file is still in `assets/` and that the render ran.
