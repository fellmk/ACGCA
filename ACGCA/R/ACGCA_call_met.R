###############################################################################
# The following code runs the growth loop after setting up a
# function.
#
# The main goal of this code is to coordinate between the R and
# C components of the program.
#
# Major additions made while fixing errors 7/4/2013 by MFK.
# I simplified the C code so only one parameter set runs at a
# time.
#
###############################################################################

#dyn.load("Rgrowthloop.so") ## see help (dyn.load)
#dyn.load("excessgrowing.so")
#dyn.load("growthloop.so")
#dyn.load("misc_func.so")
#dyn.load("misc_growth_funcs.so")
#dyn.load("putonallometry.so")
#dyn.load("rebuildstaticstate.so")
#dyn.load("shrinkingsize.so")

## Check dyn.load result to see that our C function symbol exists and
## presumably is ready to use in R:
#print(paste("growthloop loaded: ",is.loaded("Rgrowthloop"), sep=""))

###############################################################################
# This version of the growth loop is a modification for incorporating it in a
# metropolis type algorithem that will run the model until it generates
# output that is similar to values used to generate a probability array.
#
# In this version of the code the inputs are interpreted as follows
# gparms2 - input model parameters (dt, r0 etc.).
# sparms2 - input initial parameters for the model to start mcmc with
# r0 - inital radius
# dim - ?
# lenvars2 - gan get rid of this it was the length of the file
#
# VARIABLES TO ADD
# initial sigmas
# nits (iterations for comparison (acceptance rate)
#
#
# This was written by MKF 4/16/2014 as a modification of the batch version of
# the code.
###############################################################################

###############################################################################
#' ACGCA model function
#'
#' This function provides an easy interface for running the ACGCA model.
#'
#' @param sparms A vector containing the parameters for the simulation.
#' \describe{
#'    \item{hmax}{Maximum tree height}
#'    \item{phih}{Slope of H vs. r curve at r = 0 m}
#'    \item{eta}{Relative height at which trunk transitions from paraboloid to
#'     cone}
#'    \item{swmax}{Maximum sapwood width}
#'    \item{lamdas}{Proportionality between BT and BO for sapwood}
#'    \item{lamdah}{Proportionality between BT and BO for heartwood}
#'    \item{rho}{Wood density}
#'    \item{rhomin}{Not in use. Dissabled in C code}
#'    \item{f2}{Leaf area-to-xylem conducting area ratio}
#'    \item{f1}{Fine root area-to-leaf area ratio}
#'    \item{gamma}{Maximum storage capacity of living sapwood cells}
#'    \item{gammaw}{(Inverse) density of sapwood structural tissue}
#'    \item{gammax}{Xylem conducting area-to-sapwood area ratio}
#'    \item{cgl}{Construction costs of producing leaves}
#'    \item{cgr}{Construction costs of producing fine roots}
#'    \item{cgw}{Construction costs of producing sapwood} 
#'    \item{deltal}{Labile carbon storage capacity of leaves}
#'    \item{deltar}{Labile carbon storage capacity of fine roots}
#'    \item{sl}{Senescence rate of leaves} 
#'    \item{sla}{Specific leaf area}
#'    \item{sr}{Senescence rate of fine roots}
#'    \item{so}{Senescence rate of coarse roots and branches} 
#'    \item{rr}{Average fine root radius}
#'    \item{rhor}{Tissue density of fine roots}
#'    \item{rml}{Maintenance respiration rate of leaves}
#'    \item{rms}{Maintenance respiration rate of sapwood}
#'    \item{rmr}{Maintenance respiration rate of fine roots}
#'    \item{etaB}{Relative height at which trunk transitions from a neiloid to
#'     paraboloid}
#'    \item{k}{Crown light extinction coefficient}
#'    \item{epsg}{Radiation-use-efficiency}
#'    \item{m}{Maximum relative crown depth}
#'    \item{alpha}{Crown Curvature parameter}
#'    \item{R0}{Maximum potential crown radius of a tree with diameter at
#'     breast height of 0m (i.e., for a tree that is exactly 1.37 m tall}
#'    \item{R40}{Maximum potential crown radius of a tree with diameter at
#'     brrest height or 0.4m (40 cm)}
#'    \item{drinit}{NA}
#'    \item{drcrit}{NA}
#'  }
#' @param gparms A vector containing values that control simulation behavior.
#' \describe{
#'    \item{deltat}{1/16 of a year or 0.0625}
#'    \item{years}{no default}
#'    \item{tolerance}{Set to 0.00001}
#'    \item{breast height}{Set to 1.37}
#'    \item{PARmax}{Default is 2060}
#' }
#' @param r0 The starting radius. Defaults to 0.05.
#' @keywords IBM
#' @export
# @examples
#' @useDynLib ACGCA
#' @importFrom Rcpp sourceCpp
#'
###############################################################################

## This code creates the function that runs the growth loop once it is loaded
growthloopR <- function(sparms2, gparms2, r0){
  #t<- numeric(0)

  # Set up the variables needed for lengths of output
  #lenvars2 <- (gparms2[2,1]/gparms2[1,1])*dim[1]+dim[1]
  lenvars <- (gparms2[2,1]/gparms2[1,1])+1
  output2 <- list(h=numeric(0), r=numeric(0), rBH=numeric(0),
                  status=numeric(0), errorind=as.integer(numeric(0)),
                  cs=numeric(0), clr=numeric(0), 
                  growth_st=as.integer(numeric(0)))

  # Loop through each set of variables and then check the output against
  # a probability array and apply the metropolis criteria where the acceptance
  # rate should be near 0.24-0.40.  This is accomplished by modifying adjusting
  # sigma until the acceptance is 0.24-0.40 for the last 100 iterations.
  lenvars2 <- 1
  for(j in 1:lenvars2){

    # Create a vector of variables for each run
    sparms <- sparms2[,j]
    gparms <- gparms2[,j]
    r02 <- r0[j]

    output1<- .C("Rgrowthloop",p=as.double(sparms), gp=as.double(gparms),
      r0=as.double(r0), t=integer(1),
      #la=double(gparm[2]/gparm[1]+1), #// double
      #LAI=double(gparm[2]/gparm[1]+1), #//double
      #egrow=double(gparm[2]/gparm[1]+1), #//double
      #ex=double(gparm[2]/gparm[1]+1), #//double
      #status=integer(gparm[2]/gparm[1]+1) #//int
      h=double(lenvars),
      hh=double(lenvars),
      hC=double(lenvars),
      hB=double(lenvars),
      hBH=double(lenvars),
      r=double(lenvars),
      rB=double(lenvars),
      rC=double(lenvars),
      rBH=double(lenvars),
      sw=double(lenvars),
      vts=double(lenvars),
      vt=double(lenvars),
      vth=double(lenvars),
      sa=double(lenvars),
      la=double(lenvars),
      ra=double(lenvars),
      dr=double(lenvars),
      xa=double(lenvars),
      bl=double(lenvars),
      br=double(lenvars),
      bt=double(lenvars),
      bts=double(lenvars),
      bth=double(lenvars),
      boh=double(lenvars),
      bos=double(lenvars),
      bo=double(lenvars),
      bs=double(lenvars),

      cs=double(lenvars),
      clr=double(lenvars),
      fl=double(lenvars),
      fr=double(lenvars),
      ft=double(lenvars),
      fo=double(lenvars),
      rfl=double(lenvars),
      rfr=double(lenvars),
      rfs=double(lenvars),

      egrow=double(lenvars),
      ex=double(lenvars),
      rtrans=double(lenvars),
      light=double(lenvars),
      nut=double(lenvars),
      deltas=double(lenvars),
      LAI=double(lenvars),
      status=integer(lenvars),
      #dim=as.integer(dim),
      lenvars=as.integer(lenvars),

      errorind=integer(lenvars),
      growth_st=integer(lenvars)
    )# End growthloop call

    # Output to be saved this can be added to as desired
    output2$h <- c(output2$h, output1$h)
    output2$r <- c(output2$r, output1$r)
    output2$rBH <-c(output2$rBH, output1$rBH)
    output2$status <-c(output2$status, output1$status)
    output2$errorind <- c(output2$errorind, output1$errorind)

    output2$cs <- c(output2$cs, output1$cs) # Added 7/21/2014
    output2$clr <- c(output2$clr, output1$clr) # Added 7/21/2014
    output2$growth_st <-c(output2$growth_st, output1$growth_st) # Added 9/22/2014
  }#growth loop

  return(output2)

} #end of growthloop function

# I have no idea why I did this it just sends the values to another function
# without doing anything.
#growthloopR2 <- function(sparms2, gparms2, r0, dim,lenvars2){
#  growthloopR(sparms2, gparms2, r0, dim,lenvars2)
#}


