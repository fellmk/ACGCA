###############################################################################
#
# The goal of this project is to develop an ACGCA package for R.
#
# Started by Michael Fell on January 18, 2018.
#
###############################################################################

install.packages("devtools")
devtools::install_github("klutometis/roxygen")

# Load the development library and roxygen which helps with documentation.
library("devtools")
#options(devtools.install.args = "--no-multiarch")
library("roxygen2")

# A devtools function that produces a barebones folder for a package
create("ACGCA")

# I added documentation this moves into the ACGCA folder to create
# documentation.
setwd("./ACGCA")
use_rcpp()
document()

setwd("..")
install("ACGCA")
help(package="ACGCA")
library(ACGCA)

load("inputs_chain1_r00.05_PAR206_parACGCA.Rdata")
test2 <- ACGCA::growthloopR(sparms2=theta.j, gparms2=gparm, r0=0.05)

source("acruparms.R")
light.levels <- seq(1,.1,-.1)

test <- list()
test.s <- list()
for(i in 1:length(light.levels)){
  gparm[5] <- 2060*light.levels[i]
  acru <- as.matrix(acru)
  # This uses the smallest radius I can get
  test <- ACGCA::growthloopR(sparms2=acru, gparms2=gparm, r0=0.0054)
  test.s[[i]] <- test
  if(i == 1){
    plot(1:801, test$r, type="l")
  }else{
    lines(1:801, test$r, type="l")
  }
}

cbind(acru, theta.j)
# Test the scafold to make sure it runs. This call is for development and
# would in no way work with the full funciton. That should be tested using
# inputs from the origional paper by Ogle and Pacala (2009).

#ACGCArun(as.matrix(c(1, 1, 1)), as.matrix(c(1,1,1)), 1)
#dyn.load("ACGCA.dll")

