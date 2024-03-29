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
# Major modifications and error checks on the gap dynamics code were completed 
# in 2020 by MKF.
#
###############################################################################

###############################################################################
# This version of the growth loop is a modification created for use with a 
# metropolis type algorithm. It was further modified for general use in this
# R package.
#
# This was written by MKF 4/16/2014 as a modification of the batch version of
# the code.
###############################################################################

###############################################################################
#' ACGCA model function
#'
#' This function provides an easy interface for running the ACGCA model.
#'
#' @param sparms A named list containing the parameters for the simulation. For an example type 'acru' or 'pita' to see included examples.
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
#'    \item{rhor}{Tissue density of fine roots (g dw m^-3)}
#'    \item{rml}{Maintenance respiration rate of leaves (g gluc g dw^-1 year^-1)}
#'    \item{rms}{Maintenance respiration rate of sapwood (g gluc g dw^-1 year^-1)}
#'    \item{rmr}{Maintenance respiration rate of fine roots (g gluc g dw^-1 year^-1)}
#'    \item{etaB}{Relative height at which trunk transitions from a neiloid to
#'     paraboloid}
#'    \item{k}{Crown light extinction coefficient}
#'    \item{epsg}{Radiation-use-efficiency (g gluc MJ^-1)}
#'    \item{m}{Maximum relative crown depth}
#'    \item{alpha}{Crown Curvature parameter}
#'    \item{R0}{Maximum potential crown radius of a tree with diameter at
#'     breast height of 0m (i.e., for a tree that is exactly 1.37 m tall) (m)}
#'    \item{R40}{Maximum potential crown radius of a tree with diameter at
#'     breast height or 0.4m (40 cm) (m)}
#'  }
#'
#' @param r0 The starting radius. Defaults to 0.05m.
#' @param parmax The maximum yearly irradiance, defaults to 2060
#' (MJ m^-2 year^-1) and can be either a vector of length steps*years+1 or a
#' single value.
#' @param years The number of years to run the simulation, defaults to 50
#' years.
#' @param steps The number of time steps per year, defaults to 16.
#' @param breast.height The height DBH is taken at, defaults to 1.37 m.
#' @param Forparms A list of forest parameters: Forestparms = list(kF = 0.6,
#' HFmax=40, LAIFmax=6.0, infF=3.4, slopeF=-5.5). The values listed are
#' defaults based on Ogle and Pacala (2009). kF is the forest canopy light
#' extinction coefficient, HFmax is the maximum forest canopy height, LAIFmax
#' is the forest canopy maximum leaf area index, intF and slopeF are the
#' intercept and slope terms respectively when modeling the "unnormalized"
#' LAI profile (Ogle and Pacala 2009 supplement) on the logit scale.
#' @param gapvars A list of gap simulation parameters: gapvars = list(gt = 50,
#' ct=10, tbg=200). The default values are arbitrary and should be updated
#' outside of testing. The elements of the list refer to gap time (gt, years),
#' closure time (ct, years), and time between gaps (tbg, years). In the default
#' case a gap will be open for 50 years, the canopy will cose for 10 years,
#' followed by 140 years of closed canopy conditions after which a new gap will
#' form at year 201.
#' @param tolerance The tolerance for the algorithm that balances excess labile
#'   carbon in the difference equations describing carbon dynamics of a healthy
#'   tree (Ogle and Pacala, 2009). The default is 0.00001 and likely does not
#'   need to be changed.
#' @param gapsim If TRUE gap simulations will run if FALSE (default) gap
#' simulations don't run.
#' @param fulloutput Is the full output desired if so set this to TRUE. The
#'                   default is FALSE.
#' @param thin Thin the data so the output is of length (years + 1, includes 
#' initialization), defaults to TRUE.
#'
#' @return Function output:
#' \describe{
#'    \item{p}{sparms, input parameters}
#'    \item{gp}{Vector: (timestep, years, tolerance, breast.height,parmax)}
#'    \item{r0}{The starting radius (m).}
#'    \item{h}{A time series of tree height from the simulation for each time
#'    step. The length is steps*years+1 due to the initialization (time 0) (m).}
#'    \item{hh}{Height at which trunc transitions from a paraboloid to a cone.
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
#'    \item{egrow}{Excess labile carbon available for growth (g gluc year^-1)}
#'    \item{ex}{Excess labile carbon, The same as egrow (g gluc year ^-1)}
#'    \item{rtrans}{Total retranslocation fraction}
#'    \item{light}{APAR from eqn 27 in Ogle and Pacala (2009) (MJ year^-1).}
#'    \item{nut}{...}
#'    \item{deltas}{Actual labile C stored in sapwood, calculated in the
#'    growthloop (g gluc).}
#'    \item{LAI}{leaf area index (m^2/m^2}
#'    \item{status}{The status of the tree (i.e. living=1 or dead=0) at each
#'    iteration. Always 0 for the first iteration (initialization).}
#'    \item{lenvars}{The length of time series outputs steps*years+1}
#'    \item{errorind}{Contains error codes for each iteration of the model}
#'    \item{growth_st}{Growth status of the tree: 1=healthy, 2=reduced,
#'    3=recovery, 4=static, 5=shrinking, 6=dead, other=Error.}
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
runacgca <- function(sparms, r0=0.05, parmax=2060, years=50,
                        steps=16, breast.height=1.37, Forparms=list(kF=0.6,
                        HFmax=40, LAIFmax=6.0, intF=3.4, slopeF=-5.5), gapvars=list(gt=50, ct=10,
                        tbg=200), tolerance=0.00001, gapsim=FALSE,
                        fulloutput=FALSE, thin = TRUE){

  ##### Add extra variables to sparms 3/2/2018
  if(length(sparms) > 32){
    stop("The input for sparms should be a vector with 32 elements. see the
         help page for a description of each.")
  }else if(length(sparms) < 32){
    stop("The input for sparms should be a vector with 32 elements. see the
         help page for a description of each.")
  }
  
  sparms_indicator <- numeric(length(sparms))
  for(i in 1:length(sparms)){
    if(length(sparms[[i]]) == 1){
      sparms_indicator[i] <- 0
    }else if(length(sparms[[i]]) == (steps * years + 1)){
      sparms_indicator[i] <- 1
    }else{
      stop(paste0("sparms entry ", names(sparms)[i], " has length ",
                   length(sparms[[i]]), 
                   " but must be either 1 or steps x years + 1 = ", 
                   steps * years + 1))
    }
  }

  #if(gapsim==TRUE & length(parmax)>1){
  #  stop("For gap simulations the value of parmax should be scalar equal to
  #       PARmax")
  #}

  # Add values to sparms after checking its initial size
  # rhomin = 525500 (overwritten by rhomax in C)
  # gammaw = 0.000000667
  # drinit = 0.00001
  # drcrit = 0.0075
  # sparms <- c(sparms[1:7], 525000, sparms[8:10], 0.000000667, sparms[11:32],
  #             0.00001, 0.0075)
  
  additional_parameters <- list(
    # rhomin = 525500,
    rhomin = sparms$rho,
    gammaw = 0.000000667,
    drinit = 0.00001,
    drcrit = 0.0075
  )
  
  # Add values to list
  sparms <- append(sparms, additional_parameters)
  
  sparmsC <- numeric()
  startIndex <- numeric(length(sparms))*NA
  stopIndex <- numeric(length(sparms))*NA
  parameterLength <- numeric(length(sparms))*NA
  lastIndex <- 0
  
  # create a single input vector and vectors of start and stop indicies
  for(i in 1:length(sparms)){
    parameterLength[i] <- length(sparms[[i]])
    startIndex[i] <- lastIndex
    sparmsC <- c(sparmsC, sparms[[i]])
    lastIndex <- lastIndex + parameterLength[i]
    stopIndex[i] <- lastIndex-1
  }
  # print("sparmsC")
  # print(sparmsC)
  # print("startIndex")
  # print(startIndex)
  # print("stopIndex")
  # print(stopIndex)
  # print("parameterLentgh")
  # print(parameterLength)
  # print("sparmsC index test")
  # for(i in 1:length(sparms)){
  #   print(paste0("parameter: ", names(sparms)[i], " values: ", sparmsC[(startIndex[i]+1):(stopIndex[i]+1)]))
  # }
  
  

  ##### Checks added to ensure proper use 2/27/2018 #####
  # if(!is.matrix(sparms)){
  #   sparms <- as.matrix(sparms)
  # }

  #if(r0 < 0.0054){
  #  stop("The radius must be greater than 0.0054 or the function will fail.")
  #}

  if(!(is.numeric(r0)*is.numeric(parmax)*is.numeric(years)*is.numeric(steps)
       *is.numeric(breast.height)*is.numeric(tolerance))){
    stop("r0, parmax, years, steps, breast.height, and tolerance should be
         numeric.")
  }

  if(!(is.logical(fulloutput))){
    stop("fulloutput must be logical (TRUE or FALSE)")
  }

  ##### PARMAX #####
  # This can come in as a single value or as a vector. The vector should be of
  # length steps*years+1 but the user enters steps*years.
  ##################
  if(length(parmax)==1){
    parmax <- rep(x=parmax, times=(steps*years+1))
  }else if(length(parmax)!=(steps*years+1)){
    stop("Parmax should have length 1 or length steps * years + 1. The default is
         2060.")
  }

  ##### Calculate Hc and LAIF if gapsim==TRUE #####
  # The function returns Hc and LAIF
  #################################################
  if(gapsim == TRUE){
    out <- HcLAIFcalc(Forparms, gapvars, years, steps)
    # Add a zero which will be at index 0 in the C code.
    # Hc <- c(0, out$Hc)
    # LAIF <- c(0, out$LAIF)
    Hc <- out$Hc
    LAIF <- out$LAIF
	  #Hc <- out$Hc
    #LAIF <- out$LAIF
  }else{
     Hc <- rep(-99, times=(steps*years + 1))
     LAIF <- rep(0, times=(steps*years + 1))
  }

  # I replaced this in the function call with the five variables it contains.
  # It still makes sense to send a combined object to C. 2/21/18
  gparms <- matrix(data = c(1/steps, years, tolerance, breast.height), ncol=1)

  # Set up the variables needed for lengths of output
  #lenvars2 <- (gparms2[2,1]/gparms2[1,1])*dim[1]+dim[1]
  lenvars <- (gparms[2,1]/gparms[1,1]) + 1
  output2 <- list(h=numeric(0), r=numeric(0), rBH=numeric(0),
                  status=numeric(0), errorind=as.integer(numeric(0)),
                  cs=numeric(0), clr=numeric(0),
                  growth_st=as.integer(numeric(0)))

  
  #stop("STOP don't run .C right now")
  #Forparms=list(kF=0.6,
   #             HFmax=40, LAIFmax=6.0)
    # Call the growthloop function using R's C interface.
    output1<- .C("Rgrowthloop", gp=as.double(gparms),
                 Io=as.double(parmax), r0=as.double(r0), t=integer(1),
                 Hc=as.double(Hc), LAIF=as.double(LAIF),
                 kF=as.double(Forparms$kF), intF=as.double(Forparms$intF),
                 slopeF=as.double(Forparms$slopeF), 
	               APARout=double(lenvars),
                 
      h=double(lenvars),
      hh=double(lenvars),
      hC=double(lenvars),
      hB=double(lenvars),
      hBH=double(lenvars),
      r=double(lenvars),
      rB=double(lenvars),
      rC=double(lenvars), #20
      rBH=double(lenvars),
      sw=double(lenvars),
      vts=double(lenvars),
      vt=double(lenvars),
      vth=double(lenvars),
      sa=double(lenvars),
      la=double(lenvars),
      ra=double(lenvars),
      dr=double(lenvars),
      xa=double(lenvars), #30
      bl=double(lenvars),
      br=double(lenvars),
      bt=double(lenvars),
      bts=double(lenvars),
      bth=double(lenvars),
      boh=double(lenvars),
      bos=double(lenvars),
      bo=double(lenvars),
      bs=double(lenvars),

      cs=double(lenvars), #40
      clr=double(lenvars),
      fl=double(lenvars),
      fr=double(lenvars),
      ft=double(lenvars),
      fo=double(lenvars),
      rfl=double(lenvars),
      rfr=double(lenvars),
      rfs=double(lenvars),

      egrow=double(lenvars),
      ex=double(lenvars), #50
      rtrans=double(lenvars),
      light=double(lenvars),
      nut=double(lenvars),
      deltas=double(lenvars),
      LAI=double(lenvars),
      status=integer(lenvars),
      #dim=as.integer(dim),
      lenvars=as.integer(lenvars),
      errorind=integer(lenvars),
      growth_st=integer(lenvars),
      
      sparms2=as.double(sparmsC), #60
      startIndex=as.integer(startIndex),
      stopIndex=as.integer(stopIndex),
      parameterLength=as.integer(parameterLength)
      
	    # hmax=as.double(sparms$hmax), #60
	    # phih=as.double(sparms$phih),
	    # eta=as.double(sparms$eta),
	    # swmax=as.double(sparms$swmax),
	    # lamdas=as.double(sparms$lamdas),
	    # lamdah=as.double(sparms$lamdah),
	    # rhomax=as.double(sparms$rho),

      # f2=as.double(sparms$f2),
	    # f1=as.double(sparms$f1), 
	    # gammac=as.double(sparms$gammac), #70
	    
	    # gammax=as.double(sparms$gammax),
	    # cgl=as.double(sparms$cgl),
	    # cgr=as.double(sparms$cgr),
	    # cgw=as.double(sparms$cgw),
	    # deltal=as.double(sparms$deltal),
	    # deltar=as.double(sparms$deltar),
	    # sl=as.double(sparms$sl),
	    # sla=as.double(sparms$sla), 
	    # sr=as.double(sparms$sr), #80
	    # so=as.double(sparms$so),
	    # rr=as.double(sparms$rr),
	    # rhor=as.double(sparms$rhor),
	    # rml=as.double(sparms$rml),
	    # rms=as.double(sparms$rms),
	    # rmr=as.double(sparms$rmr),
	    # etaB=as.double(sparms$etaB),
	    # k=as.double(sparms$k),
	    # epsg=as.double(sparms$epsg), 
	    # M=as.double(sparms$M), #90
	    # alpha=as.double(sparms$alpha),
	    # R0=as.double(sparms$R0),
	    # R40=as.double(sparms$R40), #93,
	    # 
      # rhomin=as.double(sparms$rho), # set to rhomax. Listed as rho in papers. 
      # gammaw=as.double(gammaw), # not user defined
      # drcrit=as.double(drcrit), #96
      # drinit=as.double(drinit),
	    
	    #tolout=double(lenvars*1000),
	    #errorout=double(lenvars*1000),
	    #drout=double(lenvars*1000),
	    #demandout=double(lenvars*1000),
	    #odemandout=double(lenvars*1000),
	    #odrout=double(lenvars*1000)
    )# End growthloop call

    # Add a warning in case there was an error
    if(sum(output1$errorind) > 0){
      # Check the growth state (growth_st) to see if an error occured in the
      # root finding routine
      if (sum(output1$growth_st > 7) > 0){
        warning("An error occured and is likely related ot the root finding
                routine used in 'excessgrowing.c'. This error can occure with
                certain combinations of parameters and PARmax leading to an
                inability to balance carbon in thealgorithm.")
      }else if(sum(output1$growth_st <= 7) > 0){
        # warning("An error occured withing runacgca likely due to the set of
        #         parameters chosen or gap/light levels they are being used
        #         with.")
      }else{
        warning("An unknown error has occured within the C code that implements
                the ACGCA model.")
      }
    } # End of warning if statement.

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

      if(thin == TRUE){
        output2 = lapply(X = output2, FUN = thinvals, thin = steps)
      }
      
      return(output2)
    }else if(fulloutput == TRUE){
      # remove a few variables
      #output1[[4]] <- NULL # remove t left over from testing
      #output1[[6]] <- NULL # remove hC left over from development
      #output1[[6]] <- NULL # remove hB left over from development
      #output1[[6]] <- NULL # remove hBH left over from development
      
      if(thin == TRUE){
        output1 = lapply(X = output1, FUN = thinvalsfull, thin = steps, years = years)
      }

      return(output1)
    }else{
      stop("The fulloutput input to this function must be either TRUE or
           FALSE.")
    }
} #end of growthloop function

# A function to thin the output of the ACGCA model
thinvals <- function(x, thin = 16){
  x <- x[(((0:(length(x)-1))%%16)==0)]
  return(x)
}

thinvalsfull <- function(x, thin, years){
  if((thin*years+1) == length(x)){
    x = thinvals(x = x, thin = thin)
  }
  return(x)
}

## This code calculates Hc and LAIF for each iteration of the growthloop
# Forparms=list(kF=0.6, HFmax=40, LAIFmax=6.0),
# gapvars=list(gt=50, ct=10, tbg=200),
# mkf58 updated this function on June 12, 2020
HcLAIFcalc <- function(Forparms, gapvars, years, steps){
  # get the number of iterations and steps per year
  # gap.phase <- (years*steps)
  del.t <- steps

  closed <- gapvars$tbg-(gapvars$gt+gapvars$ct)
  if(closed < 0){
    stop("The colosed period is negative")
  }
  
  Hc_ctphase <- seq(Forparms$HFmax/(steps*gapvars$ct),Forparms$HFmax, Forparms$HFmax/(steps*gapvars$ct))
  Hf_ctphase <- seq(Forparms$LAIFmax/(steps*gapvars$ct),Forparms$LAIFmax, Forparms$LAIFmax/(steps*gapvars$ct))
  closedsteps <- (gapvars$tbg*del.t - gapvars$gt*del.t - length(Hc_ctphase))

  Hc <- c(
    rep(0,gapvars$gt*del.t),
    Hc_ctphase,
    rep(Forparms$HFmax, closedsteps)
  )
  LAIF <- c(
    rep(0, gapvars$gt*del.t),
    Hf_ctphase,
    rep(Forparms$LAIFmax, closedsteps)
  )
  
  Hc <- rep(x = Hc, length.out = (years * del.t + 1))
  LAIF <- rep(x = LAIF, length.out = (years * del.t + 1))
  
  return(list(Hc=Hc, LAIF=LAIF))
} # End of HcLAIFcalc function


