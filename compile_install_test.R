library("devtools")
options(devtools.install.args = "--no-multiarch")
library("roxygen2")

setwd("./ACGCA")
document()

setwd("..")
install("ACGCA")
help(package="ACGCA")

