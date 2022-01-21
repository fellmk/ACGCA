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

source("ACGCA/R/acru_pita_lists.R")
test <- runacgca(acru)
acru2 <- acru
acru2$sla <- seq(0.0141, 0.0141, length.out = 801)
test2 <- runacgca(acru2)
# for(i in 1:1){
#   test2 <- runacgca(acru2)
# }

plot(test2$r - test$r)

