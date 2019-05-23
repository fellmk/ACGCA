# ACGCA
R package for the ACGCA model

.libPaths( c( "/home/mkf58/R/3.5" , .libPaths() ) )
install.packages("devtools")  
library(devtools)  
devtools::install_github("fellmk/ACGCA/ACGCA", auth_token = "b3ae7ac6fc13f3c3c85a7c26975f4f0b37a60704", lib="/home/mkf58/lib/R/3.5.2")

with_libpaths(new = "/home/mkf58/lib/R/3.5.2/", install_github("fellmk/ACGCA/ACGCA", auth_token = "b3ae7ac6fc13f3c3c85a7c26975f4f0b37a60704"))

library(ACGCA, lib.loc="/home/mkf58/R/3.5")  
