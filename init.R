# init.R
#
# Example R code to install packages if not already installed
#

my_packages <- c(
  "shiny",
  "shinythemes",
  "ggplot2",
  "Hmisc",
  "reshape2",
  "dplyr",
  "ggpubr",
  "svglite",
  "markdown",
  "pkgdown",
  "DESeq2",
  "apeglm",
  "EnhancedVolcano"
  )

install_if_missing = function(p) {
  if (p %in% rownames(installed.packages()) == FALSE) {
    install.packages(p)
  }
}

invisible(sapply(my_packages, install_if_missing))

if (!require("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()