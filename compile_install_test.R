library("devtools")
options(devtools.install.args = "--no-multiarch")
library("roxygen2")

setwd("./ACGCA")
document()
devtools::build(vignettes = FALSE)

setwd("..")
install("ACGCA", build_vignettes = FALSE)

library(ACGCA)
# help(package="ACGCA")
# browseVignettes("ACGCA")

test <- runacgca(acru)
acru2 <- acru
acru2$sla <- seq(0.01, 0.02, length.out = 801)
test2 <- runacgca(acru2)

