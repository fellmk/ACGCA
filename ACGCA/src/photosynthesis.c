/// \file photosynthesis.c
/// \brief Contains function photosynthesis()
/// \author Michael Fell
/// \date 01-14-2022

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <R.h>

#include "head_files/misc_growth_funcs.h"

double photosynthesis(sparms *p, tstates *st){
    //Rprintf("epsg: %g\n", p->epsg);
    //Rprintf("light: %g\n", st->light);
    return(p->epsg*st->light);
}