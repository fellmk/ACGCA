library("devtools")
options(devtools.install.args = "--no-multiarch")
library("roxygen2")

setwd("./ACGCA")
document()
devtools::build(vignettes = TRUE)

setwd("..")
install("ACGCA", build_vignettes = TRUE)

library(ACGCA)
help(package="ACGCA")
browseVignettes("ACGCA")

# Run these to test single vs variable values
# test <- runacgca(acru)
# acru2 <- acru
# acru2$sla <- seq(0.0141, 0.0141, length.out = 801)
# test2 <- runacgca(acru2)
# plot(test2$r - test$r)
# 
# acru2$sla <- seq(0.0141, 0.2, length.out = 801)
# test2 <- runacgca(acru2)
# plot(test2$r - test$r)
