#' ACGCA package for simulating tree growth and mortality
#' 
#' The ACGCA package makes running the Allometrically Constrained Growth and 
#' Carbon Allocation model relatively easy. This package contains one function.
#' The function growthloopR() that runs the ACGCA model. Detailed documentation 
#' for the variables are available in the help file for the function and a 
#' demonstration of the functions use is available in the vignette accompanying
#' this package.
#' 
#' Compiling from source:
#' If you try to compile this package from source be aware that the gsl is 
#' required. It needs to be installed into a directory R can find or the code
#' will cause an error. In Windows the gsl can be manually compiled to a 
#' directory r searches at the time of compilation using mingw or another tool
#' with make. To compile the gsl from source run the following commands in the
#' directory with the gsl source code:
#'
#'  ./configure --prefix=PATH
#'  
#' make
#' 
#' make install
#' 
#' PATH above should be replaced with the path to the directory R will search
#' at the time of compilation. If the gsl is installed to an appropriate 
#' location compilation from source is possible in windows. In Linux 
#' compilation works as long as the gsl has been installed. In Ubuntu or any 
#' variant of it this can be accomplished via the package manager.
#' 
#' @docType package
#' @name ACGCA-package
NULL