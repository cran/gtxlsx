# Render a written workbook and compare it across gt versions.
#
# The fidelity tests compare style records: what gt declared against what the
# sheet holds. They cannot see what the sheet looks like. This renders it
# through LibreOffice instead, so two gt versions can be compared as pictures.
#
# Not part of the test suite: it needs LibreOffice, and it is slow.
#
# Usage, once per gt version:
#
#   R CMD INSTALL gt-0.8.0 && Rscript inst/examples/render-compare.R
#   R CMD INSTALL gt-1.3.0 && Rscript inst/examples/render-compare.R
#
# then compare the files it leaves in /tmp/gtxlsx-render:
#
#   soffice --headless --convert-to pdf gt-*.xlsx
#   pdftoppm -r 130 -png gt-0.8.0.pdf a && pdftoppm -r 130 -png gt-1.3.0.pdf b
#   compare -metric AE a-1.png b-1.png diff.png     # ImageMagick

library(gt)
library(openxlsx2)
library(gtxlsx)

out <- "/tmp/gtxlsx-render"
dir.create(out, showWarnings = FALSE)

# Everything here exists in gt 0.8 and later, so the same script runs on any
# version worth comparing.
d <- data.frame(
  grp   = rep(c("north", "south"), each = 3),
  size  = rep(c("S", "M", "L"), 2),
  sold  = c(6139, 4112, 4057, 2663, 3583, 5403),
  share = c(0.43, 0.28, 0.29, 0.24, 0.32, 0.44),
  stringsAsFactors = FALSE
)

tbl <- gt(d, rowname_col = "size", groupname_col = "grp")
tbl <- fmt_integer(tbl, columns = "sold")
tbl <- fmt_percent(tbl, columns = "share", decimals = 1)
tbl <- cols_label(tbl, sold = "Sold", share = "Share")
tbl <- tab_spanner(tbl, label = "2026", columns = c("sold", "share"))
tbl <- tab_header(tbl, title = "pizzaplace", subtitle = "counts by type and size")
tbl <- tab_source_note(tbl, "Source: the pizzaplace data set.")
tbl <- tab_style(tbl, cell_fill(color = "#FFE9A8"),
                 cells_body(columns = "sold", rows = 1))
tbl <- tab_style(tbl, cell_text(weight = "bold"),
                 cells_column_labels(columns = "share"))
tbl <- tab_options(tbl,
                   column_labels.background.color = "#204060",
                   table_body.hlines.style = "solid")

v <- as.character(packageVersion("gt"))
wb <- wb_workbook()$add_worksheet("t")
wb <- wb_add_gt(wb, tbl, dims = "B2")
f <- file.path(out, sprintf("gt-%s.xlsx", v))
wb_save(wb, f, overwrite = TRUE)

cat("wrote", f, "\n")

# The workbook itself is worth diffing too. Everything except docProps, which
# carries a timestamp, should be identical between versions.
cat("compare with:  unzip -o", basename(f), "-d parts-", v, "\n")
