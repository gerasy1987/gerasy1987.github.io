# R/pubs.R
#
# Builds the publication lists on the website from _bibliography/papers.bib.
# Sourced from index.qmd at render time. See README.md for the bib fields
# the site understands and how entries are sorted into sections.

for (pkg in c("RefManageR", "yaml")) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(sprintf(
      paste0(
        "Package '%s' is not installed in the R that Quarto is using (%s).\n",
        "Install it there with:  %s/bin/Rscript -e 'install.packages(\"%s\")'\n",
        "Run `quarto check` to see which R Quarto picks up."
      ),
      pkg, R.home(), R.home(), pkg
    ), call. = FALSE)
  }
}
suppressPackageStartupMessages({
  library(RefManageR)
  library(yaml)
})

BIB_FILE       <- "_bibliography/papers.bib"
COAUTHORS_FILE <- "_data/coauthors.yml"
PDF_DIR        <- "assets/pdf"
SELF_LAST      <- "Syunyaev"

# Custom (non-BibTeX) fields that are stripped from the [BibTeX] block.
HIDDEN_BIB_FIELDS <- c(
  "abbr", "abstract", "arxiv", "bibtex_show", "html", "pdf", "selected",
  "supp", "blog", "code", "poster", "slides", "website", "pap", "media",
  "status", "preprint"
)

`%||%` <- function(a, b) if (is.null(a) || length(a) == 0 || !nzchar(a[1])) b else a

html_escape <- function(x) {
  x <- gsub("&", "&amp;", x, fixed = TRUE)
  x <- gsub("<", "&lt;", x, fixed = TRUE)
  gsub(">", "&gt;", x, fixed = TRUE)
}

# TeX-style quotes and dashes to typographic ones, for titles and notes.
tidy_text <- function(x) {
  if (is.null(x)) return(NULL)
  x <- gsub("``", "“", x, fixed = TRUE)
  x <- gsub("''", "”", x, fixed = TRUE)
  x <- gsub("---", "—", x, fixed = TRUE)
  x <- gsub("--", "–", x, fixed = TRUE)
  x <- gsub("[{}]", "", x)
  x
}

# ---------------------------------------------------------------------------
# Loading
# ---------------------------------------------------------------------------

load_pubs <- function(bib_file = BIB_FILE, coauthors_file = COAUTHORS_FILE) {
  bib <- ReadBib(bib_file, check = FALSE)
  raw <- readLines(bib_file, warn = FALSE, encoding = "UTF-8")
  coauthors <- if (file.exists(coauthors_file)) yaml::read_yaml(coauthors_file) else list()

  entries <- lapply(seq_along(bib), function(i) bib[[i]])
  types   <- tolower(vapply(entries, function(e) e$bibtype, character(1)))
  status  <- vapply(entries, function(e) tolower(e$status %||% ""), character(1))
  years   <- suppressWarnings(as.integer(vapply(entries, function(e) e$year %||% NA_character_, character(1))))

  published <- entries[types %in% c("article", "inproceedings", "incollection", "book")]
  pub_years <- years[types %in% c("article", "inproceedings", "incollection", "book")]
  # Newest first; ties keep the order in the bib file.
  published <- published[order(-pub_years, seq_along(published), na.last = TRUE)]

  # status = wp puts an unpublished/misc entry under Working Papers; any other
  # status (design, implementation, analysis, manuscript, ...) puts it under
  # Work in Progress. The note field carries the stage text that is displayed.
  is_paper   <- types %in% c("unpublished", "misc", "techreport")
  working    <- entries[is_paper & status == "wp"]
  inprogress <- entries[is_paper & status != "wp"]
  software   <- entries[types == "manual"]

  list(
    published = published,
    working = working,
    inprogress = inprogress,
    software = software,
    raw = raw,
    coauthors = coauthors
  )
}

# ---------------------------------------------------------------------------
# Authors
# ---------------------------------------------------------------------------

coauthor_url <- function(family, given, coauthors) {
  cands <- coauthors[[family]]
  if (is.null(cands)) return(NULL)
  first_token <- strsplit(given, " ")[[1]][1]
  for (c in cands) {
    variants <- unlist(c$firstname)
    if (given %in% variants || first_token %in% variants) return(c$url)
  }
  NULL
}

fmt_person <- function(p, coauthors) {
  family <- paste(p$family, collapse = " ")
  given  <- paste(p$given, collapse = " ")
  if (family == "others") {
    return(if (grepl("^[0-9]+$", given)) paste(given, "others") else "others")
  }
  full <- trimws(paste(given, family))
  url <- coauthor_url(family, given, coauthors)
  if (!is.null(url)) sprintf('<a href="%s">%s</a>', url, full) else full
}

join_names <- function(n) {
  if (length(n) == 0) return("")
  if (length(n) == 1) return(n)
  if (length(n) == 2) return(paste(n, collapse = " and "))
  paste0(paste(n[-length(n)], collapse = ", "), ", and ", n[length(n)])
}

# "(with A, B, and C)" when I am an author; a plain author list otherwise.
fmt_authors <- function(e, coauthors) {
  persons <- e$author
  if (is.null(persons)) return("")
  fam <- vapply(persons, function(p) paste(p$family, collapse = " "), character(1))
  is_self <- fam == SELF_LAST
  names <- vapply(persons, fmt_person, character(1), coauthors = coauthors)
  if (any(is_self)) {
    others <- names[!is_self]
    if (length(others) == 0) return("")
    sprintf("(with %s)", join_names(others))
  } else {
    join_names(names)
  }
}

# ---------------------------------------------------------------------------
# Venue line
# ---------------------------------------------------------------------------

fmt_venue <- function(e) {
  type <- tolower(e$bibtype)
  yr   <- e$year
  pages <- tidy_text(e$pages)
  if (type == "article") {
    s <- sprintf("<i>%s</i>", tidy_text(e$journal))
    if (!is.null(e$volume)) {
      s <- paste0(s, ", ", e$volume)
      if (!is.null(e$number)) s <- paste0(s, " (", e$number, ")")
      if (!is.null(pages)) s <- paste0(s, ": ", pages)
    } else if (!is.null(pages)) {
      s <- paste0(s, ", ", pages)
    }
    s <- paste0(s, ".")
    return(if (!is.null(yr)) paste0(yr, ". ", s) else s)
  }
  if (type %in% c("inproceedings", "incollection")) {
    eds <- if (!is.null(e$editor)) {
      join_names(vapply(e$editor, function(p) trimws(paste(paste(p$given, collapse = " "), paste(p$family, collapse = " "))), character(1)))
    } else NULL
    s <- "In "
    if (!is.null(eds)) s <- paste0(s, eds, " (eds.), ")
    s <- paste0(s, sprintf("<i>%s</i>", tidy_text(e$booktitle)))
    if (!is.null(e$publisher)) s <- paste0(s, ", ", tidy_text(e$publisher))
    if (!is.null(pages)) s <- paste0(s, ", ", pages)
    s <- paste0(s, ".")
    return(if (!is.null(yr)) paste0(yr, ". ", s) else s)
  }
  # Working papers, work in progress, software: the note carries the status.
  s <- tidy_text(e$note %||% "")
  if (!nzchar(s)) return("")
  s <- paste0(s, ".")
  if (!is.null(yr)) paste0(yr, ". ", s) else s
}

# ---------------------------------------------------------------------------
# Links
# ---------------------------------------------------------------------------

asset_url <- function(x, dir) {
  if (grepl("://", x, fixed = TRUE) || startsWith(x, "/")) x else file.path(dir, x)
}

title_url <- function(e) {
  u <- e$html %||% e$url %||% NULL
  if (is.null(u) && !is.null(e$doi)) {
    u <- if (grepl("://", e$doi, fixed = TRUE)) e$doi else paste0("https://doi.org/", e$doi)
  }
  if (is.null(u) && !is.null(e$preprint)) u <- e$preprint
  if (is.null(u) && !is.null(e$pdf)) u <- asset_url(e$pdf, PDF_DIR)
  if (is.null(u) && !is.null(e$code)) u <- e$code
  u
}

link <- function(label, href) sprintf('<a href="%s">[%s]</a>', href, label)
toggle <- function(label, id) {
  sprintf('<a href="#" class="toggle" data-target="%s" role="button" aria-expanded="false" aria-controls="%s">[%s]</a>', id, id, label)
}

# pap = {https://...}                       -> [Pre-analysis plan]
# pap = {https://...; https://...}          -> [Pre-analysis plan 1] [Pre-analysis plan 2]
# pap = {Survey|https://...; GOTV|https://...} -> [Pre-analysis plan: Survey] [Pre-analysis plan: GOTV]
pap_links <- function(pap) {
  items <- trimws(strsplit(pap, ";", fixed = TRUE)[[1]])
  items <- items[nzchar(items)]
  if (length(items) == 1 && !grepl("|", items, fixed = TRUE)) {
    return(link("Pre-analysis plan", items))
  }
  vapply(seq_along(items), function(i) {
    parts <- trimws(strsplit(items[i], "|", fixed = TRUE)[[1]])
    if (length(parts) >= 2) {
      link(paste0("Pre-analysis plan: ", html_escape(parts[1])), parts[2])
    } else {
      link(paste("Pre-analysis plan", i), parts[1])
    }
  }, character(1))
}

fmt_links <- function(e, key) {
  out <- character(0)
  if (!is.null(e$abstract)) out <- c(out, toggle("Abstract", paste0("abs-", key)))
  if (!is.null(e$preprint)) out <- c(out, link("Preprint", e$preprint))
  if (!is.null(e$pdf))      out <- c(out, link("PDF", asset_url(e$pdf, PDF_DIR)))
  if (!is.null(e$supp))     out <- c(out, link("Supplement", asset_url(e$supp, PDF_DIR)))
  if (!is.null(e$pap))      out <- c(out, pap_links(e$pap))
  if (!is.null(e$code))     out <- c(out, link("Code", e$code))
  if (!is.null(e$slides))   out <- c(out, link("Slides", asset_url(e$slides, PDF_DIR)))
  if (!is.null(e$poster))   out <- c(out, link("Poster", asset_url(e$poster, PDF_DIR)))
  if (isTRUE(tolower(e$bibtex_show %||% "false") == "true")) {
    out <- c(out, toggle("BibTeX", paste0("bib-", key)))
  }
  if (length(out) == 0) return("")
  paste0('<span class="pub-links">', paste(out, collapse = " "), "</span>")
}

# media = {Outlet|https://...; Other outlet|https://...}
# A bare URL without a label is shown under its host name.
fmt_media <- function(e) {
  if (is.null(e$media)) return("")
  items <- trimws(strsplit(e$media, ";", fixed = TRUE)[[1]])
  items <- items[nzchar(items)]
  links <- vapply(items, function(it) {
    parts <- trimws(strsplit(it, "|", fixed = TRUE)[[1]])
    if (length(parts) >= 2) {
      sprintf('<a href="%s">%s</a>', parts[2], html_escape(parts[1]))
    } else {
      host <- sub("^https?://(www\\.)?([^/]+).*$", "\\2", parts[1])
      sprintf('<a href="%s">%s</a>', parts[1], host)
    }
  }, character(1))
  sprintf('<div class="media-links">[Media: %s]</div>', paste(links, collapse = ", "))
}

# ---------------------------------------------------------------------------
# Raw BibTeX for the [BibTeX] block
# ---------------------------------------------------------------------------

raw_bibtex <- function(key, raw) {
  start <- grep(sprintf("^@\\w+\\s*\\{\\s*%s\\s*,", key), raw)
  if (length(start) == 0) return(NULL)
  start <- start[1]
  depth <- 0
  end <- NA
  for (i in start:length(raw)) {
    opens  <- lengths(regmatches(raw[i], gregexpr("{", raw[i], fixed = TRUE)))
    closes <- lengths(regmatches(raw[i], gregexpr("}", raw[i], fixed = TRUE)))
    depth <- depth + opens - closes
    if (depth <= 0) { end <- i; break }
  }
  if (is.na(end)) return(NULL)
  lines <- raw[start:end]
  pat <- sprintf("^\\s*(%s)\\s*=", paste(HIDDEN_BIB_FIELDS, collapse = "|"))
  lines <- lines[!grepl(pat, lines)]
  paste(lines, collapse = "\n")
}

# ---------------------------------------------------------------------------
# One entry
# ---------------------------------------------------------------------------

fmt_entry <- function(e, pubs) {
  key <- e$key
  title <- tidy_text(e$title)
  u <- title_url(e)
  title_html <- if (!is.null(u)) sprintf('<b><a href="%s">%s</a></b>', u, title) else sprintf("<b>%s</b>", title)

  authors <- fmt_authors(e, pubs$coauthors)
  venue   <- fmt_venue(e)
  links   <- fmt_links(e, key)

  # "<b>Title</b> (with A and B). 2021. <i>Journal</i>, ... [links]"; the period
  # after the title or author list separates it from the venue line.
  head <- title_html
  if (nzchar(authors)) head <- paste(head, authors)
  if (nzchar(venue))   head <- paste0(head, ". ", venue)
  if (nzchar(links))   head <- paste(head, links)

  blocks <- character(0)
  if (!is.null(e$abstract)) {
    blocks <- c(blocks, sprintf('<div id="abs-%s" class="toggle-body" hidden>%s</div>', key, tidy_text(e$abstract)))
  }
  if (isTRUE(tolower(e$bibtex_show %||% "false") == "true")) {
    bt <- raw_bibtex(key, pubs$raw)
    if (!is.null(bt)) {
      blocks <- c(blocks, sprintf('<div id="bib-%s" class="toggle-body" hidden><pre>%s</pre></div>', key, html_escape(bt)))
    }
  }
  media <- fmt_media(e)

  paste0("<li>\n", head, "\n", paste(blocks, collapse = "\n"), if (length(blocks)) "\n" else "", media, if (nzchar(media)) "\n" else "", "</li>\n")
}

# Prints a <ul> for a vector of entries. Call inside a chunk with `output: asis`.
pub_list <- function(entries, pubs) {
  if (length(entries) == 0) return(invisible(NULL))
  cat('<ul class="pubs">\n')
  for (e in entries) cat(fmt_entry(e, pubs))
  cat("</ul>\n")
  invisible(NULL)
}
