library("devtools")
options(devtools.install.args = "--no-multiarch")
library("roxygen2")

setwd("./ACGCA")
document()
devtools::build(vignettes = TRUE)

setwd("..")
install("ACGCA", build_vignettes = TRUE)

library(ACGCA)
#help(package="ACGCA")
browseVignettes("ACGCA")
