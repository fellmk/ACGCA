# ACGCA
## Table of contents
* [Overview](#overview)
  * [Using the ACGCA model](#using-the-acgca-model)
    * [Installing the ACGCA Package](#installation)
    * [Quick Test](#quicktest)
* [Advanced](#advanced)
* [References](#references)

## Overview
The Allometrically Constrained Growth and Carbon Allocation (ACGCA) model is an individually based model of tree growth and mortality originally developed by Ogle and Pacala (2009). As the name implies the ACGCA model makes use of functional traits and allometries between tissue types (i.e. leaves, roots, and stems) to determine carbon allocation in a tree.

Carbon dynamics within the tree are essential to this model. Carbon is allocated between a structural and two storage pools in a way that satisfies the aforementioned allometric relationships (Ogle and Pacala (2009). One storage pool is associated with leaf and fine root tissue. Labile carbon in this pool is retranslocated when the tissue senesceses (Ogle and Pacala 2009). The other storage pool is in the sapwood and is used in times of stress (high labile carbon demand relative to carbon inputs). Finally there is a transient labile carbon pool representative of recent photosynthate and retranslocated carbon. It is not associated with a specific tissue and is immediately redistributed within the tree to accommodate biomass production, respiration, and allocation to storage. If the labile carbon available to the tree is depleted the tree dies (Ogle and Pacala 2009).

There are six possible physiological states in the ACGCA model: healthy, static, shrinking, recovering, recovered, or dead (Ogle and Pacala 2009). Each state is described by a set of difference equations satisfying mass-balance relationshipts between structural and labile carbon pools. The only environmental driver included in the model is parmax (annual radiation for a site).

For a full description of the model see Ogle and Pacala (2009) and the accompanying supplemental material. The model has also been used in several other studies (Fell et al. 2018 and Gemoets et al 2013).

## Using the ACGCA model
### Installing the ACGCA Package
To install the ACGCA package run the following commands.
```{R}
.libPaths()
install.packages("devtools")  
library(devtools)  
devtools::install_github("fellmk/ACGCA/ACGCA", lib="LIBRARYPATH")
library(ACGCA)
```
The first command `.libPaths()` is not necessarily needed but will list available R libraries on your system. The second line installs the devtools package which is required for installing the ACGCA package. The third line loads devtools. The final two lines install and load the ACGCA package. Where `lib="LIBRARYPATH"` insert the R library where you would like the package to install. The default will be used if this is not specified.

### Quick Test
Run a quick test to make sure the ACGCA model is working
```{R}
test <- runacgca(sparms = acru, parmax = 1000, years = 50, steps = 16) # acru contains a set of parameters
plot(x=1:800/16, y = test$h, type="l", xlab = "time (years)", ylab = "height (m)")
```
## Advanced
While we tried to address general use cases there is always the possibility an intrepid user will want to modify the C code underlying the model. This section covers some basics to make the process a little easier for advanced users. 

### Getting the Necessary Files
Rather than installing the package with `devtools` as shown above it is also possible to obtain a copy of the entire repository. This can be done in several ways. 
* Click 'Code' button above and select 'Download ZIP'. 
* Download using a terminal `git clone https://github.com/fellmk/ACGCA.git`.
* Fork the repository (click 'Fork' button at the top of the page).

### Modifying Carbon Inputs (Photosynthesis)
The model of photosynthesis used in the model is extreamly simple (Ogle and Pacala 2009). It can be modified by changing the code in `photosynthesis.c` and `photosynthesis.h`. It may also be necessary to modify the inputs to this code on line 300 of `growthloop.c`. Currently the state vector and tree trait values are passed to the `photosynthesis(p, &st)` function. The struct `st` contains the state variables of the tree (most of the values are covered in the R help file as outputs) for the current timestep. The values that are output to R are stored into vectors at the end of the `growthloop()` function. The input `p` is a pointer to a struct containing the tree's trait values passed from R. Other parameters for a model could be added but they would either need to be passed into the growthloop from R or read into a new function directly from a data file. 

### Adding C inputs
Due to the limitations of the `.C()` function in R used to run C code only 65 arguments can be passed to C. To add new inputs the easiest approach is to add them to the sparms list. A block of code in `ACGCA_call_met.R` in the R source folder converts the list to a vector and produces a variable containing the start index for each input as well as its length. These values are used to convert the values back into unique variables in C within `Rgrowthloop.c`. For each new input memory needs to be allocated in C. This is done as shown below for hmax. the index for the variable is the possition in the sparms list in R minus 1. 
```{C}
	double *hmax;
	drcrit = malloc(parameterLength[0]*sizeof(double));
```
The new variable in C then needs to have values read into it. Given all values in sparms are assumed to be of length 1 or `steps * years + 1` for loops are used to populate the variables passed to `growthloop.c` as follows:
```{C}
	for(int i=0; i < parameterLength[0]; i++){
		int index = startIndex[0] + i;
		hmax[i] = sparms2[index];
	}
```
Code should also be added to the end of `Rgrowthloop.c` to free the memory before execution is returned to R after the growthloop finishes running. this is done by adding a `free()` call at the end of the file.
```{C}
free(hmax);
```
The variable also needs to be added to the call for the growthloop in `Rgrowthloop.c` as well as to the function declaration in `growthloop.c` and its header file `growthloop.h`. At this point the variable can be used within the growthloop. 

## References

Fell, M., J. Barber, J. W. Lichstein, and K. Ogle. 2018. Multidimensional trait space informed by a mechanistic model of tree growth and carbon allocation. Ecosphere 9. DOI:10.1002/ecs2.2060

Gemoets, D., J. Barber, and K. Ogle. 2013. Reversible jump MCMC for inference in a deterministic individual-based model of tree growth for studying forest dynamics. Environmetrics 24:433–448.

Ogle, K., and S. W. Pacala. 2009. A modeling framework for inferring tree growth and allocation from physiological, morphological and allometric traits. Tree Physiology 29:587–605.
