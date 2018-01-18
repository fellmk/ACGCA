###############################################################################
#
# The goal of this project is to develop an ACGCA package for R.
#
# Started by Michael Fell on January 18, 2018.
#
###############################################################################

install.packages("devtools")
devtools::install_github("klutometis/roxygem")

# Load the development library and roxygen which helps with documentation.
library("devtools")
library("roxygen2")

# A devtools function that produces a barebones folder for a package
create("ACGCA")

# I added documentation this moves into the ACGCA folder to create
# documentation.
setwd("./ACGCA")
document()

setwd("..")
install("ACGCA")
help(package="ACGCA")

# Test the scafold to make sure it runs. This call is for development and
# would in no way work with the full funciton. That should be tested using 
# inputs from the origional paper by Ogle and Pacala (2009).
ACGCArun(as.matrix(c(1, 1, 1)), as.matrix(c(1,1,1)), 1)

