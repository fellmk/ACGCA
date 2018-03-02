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
#'    \item{hmax}{Maximum tree height (m)}
#'    \item{phih}{Slope of H vs. r curve at r = 0 m}
#'    \item{eta}{Relative height at which trunk transitions from paraboloid to
#'     cone}
#'    \item{swmax}{Maximum sapwood width (m)}
#'    \item{lamdas}{Proportionality between BT and BO for sapwood}
#'    \item{lamdah}{Proportionality between BT and BO for heartwood}
#'    \item{rho}{Wood density (g dw m^-3)}
#'    \item{f2}{Leaf area-to-xylem conducting area ratio}
#'    \item{f1}{Fine root area-to-leaf area ratio}
#'    \item{gammac}{Maximum storage capacity of living sapwood cells 
#'    (g gluc m^2)}
#'    \item{gammax}{Xylem conducting area-to-sapwood area ratio}
#'    \item{cgl}{Construction costs of producing leaves (g gluc g dw^-1))}
#'    \item{cgr}{Construction costs of producing fine roots (g gluc g dw^-1)}
#'    \item{cgw}{Construction costs of producing sapwood (g gluc g dw^-1)}
#'    \item{deltal}{Labile carbon storage capacity of leaves (g gluc g dw^-1)}
#'    \item{deltar}{Labile carbon storage capacity of fine 
#'    roots(g gluc g dw^-1)}
#'    \item{sl}{Senescence rate of leaves (yr^-1)}
#'    \item{sla}{Specific leaf area (m^2 g dw^-1)}
#'    \item{sr}{Senescence rate of fine roots (yr^-1)}
#'    \item{so}{Senescence rate of coarse roots and branches (yr^-1)}
#'    \item{rr}{Average fine root radius (m)}
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
#'  }
#'
#' @param r0 The starting radius. Defaults to 0.05
#' @param parmax The maximum yearly iradiance, defaults to 2060
#' @param years The number of years to run the simulation, defaults to 50.
#' @param steps The number of time steps per year, defaults to 16.
#' @param breast.height The height DBH is taken at, defaults to 1.37.
#' @param tolerance The tolerance for the algorithm that balances excess labile
#'   carbon in the difference equations describing carbon dynamics of a healthy
#'   tree (Ogle and Pacala, 2009). The default is 0.00001 and should likely not
#'   be changed.
#' @param fulloutput Is the full output desired if so set this to TRUE. The
#'                   default is FALSE.
#'
#' @return Function output:
#' \describe{
#'    \item{p}{sparms, input parameters}
#'    \item{gp}{Vector: (timestep, years, tolerance, breast.height,parmax)}
#'    \item{r0}{The starting radius.}
#'    \item{h}{A time series of tree height from the simulation for each time
#'    step. The length is steps*years+1 due to the initialization (time 0).}
#'    \item{hh}{Height at which trunc transitions from a paraaboloid to a cone.
#'    Also the height to the base of the crown (m).}
#'    \item{r}{A time series of tree radius (m) from the simulation for each
#'    time step. The length is steps*years+1
#'    (time 0).}
#'    \item{rB}{Radius at the tree's base (m).}
#'    \item{rBH}{Radius at breast height (3.37 m).}
#'    \item{sw}{Sapwood width which has a maximum of SWmax (m).}
#'    \item{vts}{Volume of trunk sapwood (m^3).}
#'    \item{vt}{Volume of trunk (m^3).}
#'    \item{vth}{Volume of trunk heartwood (m^3).}
#'    \item{sa}{Sapwood area at base of trunk (m^2).}
#'    \item{la}{Total one-sided leaf area (m^2).}
#'    \item{ra}{Fine root area (m^2)}
#'    \item{dr}{incremental increase in radius}
#'    \item{xa}{Not in use}
#'    \item{bl}{Biomass of leaves (g dw)}
#'    \item{br}{Biomass of roots (g dw)}
#'    \item{bt}{Biomass of trunk (g dw)}
#'    \item{bts}{Biomass of trunk sapwood (g dw)}
#'    \item{bth}{Biomass of trunk heartwood (g dw)}
#'    \item{boh}{Biomass of other (e.g., coarse roots branches) heartwood 
#'    (g dw)}
#'    \item{bos}{Biomass of other sapwood (g dw)}
#'    \item{bo}{Biomass of other wood (coarse roots, branches)}
#'    \item{bs}{Biomass of sapwood (trunk, coarse roots, branches, g dw)}
#'    \item{cs}{Labile carbon in sapwood (g glucose)}
#'    \item{clr}{Labile carbon in leaves and fine roots (g glucose)}
#'    \item{fl}{Fraction of excess labile barbon (E) allocated to leaves}
#'    \item{fr}{Fraction of E allocated to fine roots}
#'    \item{ft}{Fraction of E allocated to trunk}
#'    \item{fo}{Fraction of E allocated to coarse roots and branches}
#'    \item{rfl}{Retranslocation fraction leaves}
#'    \item{rfr}{Retranslocation fraction roots}
#'    \item{rfs}{Retranslocation fraction stem}
#'    \item{egrow}{Excess labile carbon available for growth}
#'    \item{ex}{Excess labile carbon, The same as egrow}
#'    \item{rtrans}{Total retranslocation fraction}
#'    \item{light}{APAR from eqn 27 in Ogle and Pacala (2009).}
#'    \item{nut}{...}
#'    \item{deltas}{Actual labile C stored in sapwood, calculated in the 
#'    growthloop.}
#'    \item{LAI}{leaf area index (m^2/m^2}
#'    \item{status}{The status of the tree (i.e. living=1 or dead=0) at each 
#'    iteration. Always 0 for the first iteration (initialization).}
#'    \item{lenvars}{The length of time series outputs steps*years+1}
#'    \item{errorind}{Contains error codes for each iteration of the model}
#'    \item{growth_st}{Growth status of the tree: 1=healthy, 2=reduced, 
#'    3=recovery, 4=static, 5=shrinking, 6=dead.}
#' }
#'
#' @keywords IBM
#' @export
# @examples
#' @useDynLib ACGCA
#' @importFrom Rcpp sourceCpp
#'
###############################################################################

## This code creates the function that runs the growth loop once it is loaded
growthloopR <- function(sparms, r0=0.05, parmax=2060, years=50,
                        steps=16, breast.height=1.37, tolerance=0.00001,
                        fulloutput=FALSE){

  ##### Add extra variables to sparms 3/2/2018
  if(length(sparms) > 32){
    stop("The input for sparms should be a vector with 32 elements. see the 
         help page for a description of each.")
  }
  # Add values to sparms after checking its initial size
  sparms <- c(sparms[1:7], 525000, sparms[8:10], 0.000000667, sparms[11:32], 
              0.00001, 0.0075)
  
  ##### Checks added to ensure proper use 2/27/2018 #####
  if(!is.matrix(sparms)){
    sparms <- as.matrix(sparms)
  }
  
  if(r0 < 0.0054){
    stop("The radius must be greater than 0.0054 or the function will fail.") 
  }
  
  if(!(is.numeric(r0)*is.numeric(parmax)*is.numeric(years)*is.numeric(steps)
       *is.numeric(breast.height)*is.numeric(tolerance))){
    stop("r0, parmax, years, steps, breast.height, and tolerance should be 
         numeric.")
  }
  
  if(!(is.logical(fulloutput))){
    stop("fulloutput must be logical (TRUE or FALSE)") 
  }
  
  # I replaced this in the function call with the five variables it contains.
  # It still makes sense to send a combined object to C. 2/21/18
  gparms <- matrix(data = c(1/steps, years, tolerance, breast.height, parmax), ncol=1)

  # Set up the variables needed for lengths of output
  #lenvars2 <- (gparms2[2,1]/gparms2[1,1])*dim[1]+dim[1]
  lenvars <- (gparms[2,1]/gparms[1,1])+1
  output2 <- list(h=numeric(0), r=numeric(0), rBH=numeric(0),
                  status=numeric(0), errorind=as.integer(numeric(0)),
                  cs=numeric(0), clr=numeric(0),
                  growth_st=as.integer(numeric(0)))

    # Call the growthloop function using R's C interface.
    output1<- .C("Rgrowthloop",p=as.double(sparms), gp=as.double(gparms),
      r0=as.double(r0), t=integer(1),

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

    if(fulloutput == FALSE){
      # Output to be saved this can be added to as desired
      output2$h <- c(output2$h, output1$h)
      output2$r <- c(output2$r, output1$r)
      output2$rBH <-c(output2$rBH, output1$rBH)
      output2$status <-c(output2$status, output1$status)
      output2$errorind <- c(output2$errorind, output1$errorind)
      output2$cs <- c(output2$cs, output1$cs) # Added 7/21/2014
      output2$clr <- c(output2$clr, output1$clr) # Added 7/21/2014
      output2$growth_st <-c(output2$growth_st, output1$growth_st) # Added 9/22/2014

      return(output2)
    }else if(fulloutput==TRUE){
      # remove a few variables
      output1[[4]] <- NULL # remove t left over from testing
      output1[[6]] <- NULL # remove hC left over from development
      output1[[6]] <- NULL # remove hB left over from development
      output1[[6]] <- NULL # remove hBH left over from development
      
      return(output1)
    }else{
      stop("The fulloutput input to this function must be either TRUE or
           FALSE.")
    }
} #end of growthloop function
