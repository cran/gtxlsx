# What gt_split() does to a six row table, split into two.
library(gt)
cat("gt version:", as.character(packageVersion("gt")), "\n\n")

d  <- data.frame(name = paste0("row", 1:6), value = 1:6)
sp <- gt_split(gt(d), row_every_n = 3)

shown <- function(tbl) {
  h <- as.character(as_raw_html(tbl, inline_css = FALSE))
  cells <- regmatches(h, gregexpr("<td[^>]*>[^<]*</td>", h))[[1]]
  gsub("<[^>]*>", "", cells)
}

for (i in seq_len(nrow(sp$gt_tbls))) {
  t <- grp_pull(sp, i)
  cat("--- table", i, "---\n")
  cat("  data it holds :", paste(t$`_data`$name, collapse = ", "), "\n")
  cat("  what it shows :", paste(shown(t), collapse = ", "), "\n\n")
}
