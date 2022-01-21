#include "head_files/misc_growth_funcs.h"
#include "head_files/growthloop.h"
#include <R.h>

//////////////////////////////////////////////////////////////////////////////////
// This code is to create a call to the growthloop from R
// I am hoping to avoid the structure that is causing problems.
// I need to create the structures needed by the growth loop but they need to be
// pointers so I need to send the variables to the loop indirectly.  The goal
// of the below function is to do this.  MKF 03/26/2013
//////////////////////////////////////////////////////////////////////////////////
// changes added Hc, LAIf,
void Rgrowthloop(double *gp2, double *Io, double *r0, int *t,
	double *Hc, double *LAIF, double *kF, double *intF, double *slopeF, 
	double *APARout,

	double *h,
	double *hh,
	double *hC,
	double *hB,
	double *hBH,
	double *r,
	double *rB,
	double *rC, //20
	double *rBH,
	double *sw,
	double *vts,
	double *vt,
	double *vth,
	double *sa,
	double *la,
	double *ra,
	double *dr,
	double *xa, //30
	double *bl,
	double *br,
	double *bt,
	double *bts,
	double *bth,
	double *boh,
	double *bos,
	double *bo,
	double *bs,

	double *cs, //40
	double *clr,
	double *fl,
	double *fr,
	double *ft,
	double *fo,
	double *rfl,
	double *rfr,
	double *rfs,

	double *egrow,
	double *ex, //50
	double *rtrans,
	double *light,
	double *nut,
	double *deltas,
	double *LAI,
	int *status,
	//int *dim,
	int *lenvars,
	int *errorind,
  	int *growth_st,
	  
	double *sparms2, //60
	int *startIndex,
	int *stopIndex,
	int *parameterLength

	// double *hmax, //60
	// double *phih,
	// double *eta,
	// double *swmax,
	// double *lamdas,
	// double *lamdah,
	// double *rhomax,
	// double *rhomin,
	// double *f2,
	// double *f1,
	// double *gammac, //70
	// double *gammaw,
	// double *gammax,
	// double *cgl,
	// double *cgr,
	// double *cgw,
	// double *deltal,
	// double *deltar,
	// double *sl,
	// double *sla,
	// double *sr, //80
	// double *so,
	// double *rr,
	// double *rhor,
	// double *rml,
	// double *rms,
	// double *rmr,
	// double *etaB,
	// double *k,
	// double *epsg,
	// double *M, //90
	// double *alpha,
	// double *R0,
	// double *R40, //93

	// int *sparms_indicator,
	// double *drinit,
	// double *drcrit
	)
  //double *tolout,
  //double *errorout,
  //double *drout,
  //double *demandout,
  //double *odemandout,
  //double *odrout)
{
	// Rprintf("start function. \n");

	// Rprintf("sparms2 values: \n");
	// for(int i = 0; i < 36; i++){
	// 	Rprintf("%g\n", sparms2[i]);
	// }
	///////////////////////////////////////////////////////////////////////////
	// Declare two structs and use them to store the simulation parameters
	// and the simulation control variables.
	///////////////////////////////////////////////////////////////////////////
	sparms p;
  	gparms gp;

	// // NOTE: all indicies -1 because C starts at 0 while R starts at 1
	// // Define p(plant) parameters based on R array
	// p.hmax = p2[0];
	// p.phih = p2[1];
	// p.eta = p2[2];
	// p.swmax = p2[3]; //exp(-3.054);
	// p.lamdas = p2[4];
	// p.lamdah = p2[5];
	// p.rhomax = p2[6]; //exp(13.2);
	// p.rhomin = p2[7]; //exp(13.2);
	// p.rhomin = p.rhomax; // this could be changed if rhomin != rhomax.
	// p.f2 = p2[8]; //exp(8.456);//   //f2=gammax*NEWf2
	// p.f1 = p2[9];
	// p.gammac = p2[10];
	// p.gammaw = p2[11];
	// p.gammax = p2[12]; //inv_logit(-0.709);//
	// p.cgl = p2[13]; //exp(0.3229);//
	// p.cgr = p2[14]; //exp(0.192);//
	// p.cgw = p2[15]; //exp(0.3361);//
	// p.deltal = p2[16];//inv_logit(-2.276);//
	// p.deltar = p2[17]; //inv_logit(-2.832);//
	// p.sl = p2[18]; //exp(0.8133);//
	// p.sla = p2[19]; //exp(-4.119);//
	// p.sr = p2[20]; //exp(0.2493);//
	// p.so = p2[21]; //exp(0.6336); //
	// p.rr = p2[22]; //exp(-8.103); //
	// p.rhor = p2[23]; // new value: exp(-1.724);
	// p.rml = p2[24]; //exp(2.544);//
	// p.rms = p2[25]; //exp(0.5499); //
	// p.rmr = p2[26]; //exp(3.252);//
	// p.etaB = p2[27];
	// p.K = p2[28];
	// p.epsg = p2[29]; //exp(-3.304); //6.75;
	// p.M = p2[30];
	// p.alpha = p2[31];
	// p.R0 = p2[32];
	// p.R40 = p2[33];
	// p.drinit = p2[34];
	// p.drcrit = p2[35];

	// Create sparms2 variables using vectors from R, MKF January 20, 2022
	double *hmax;
	hmax = malloc(parameterLength[0]*sizeof(double));
	double *phih;
	phih = malloc(parameterLength[1]*sizeof(double));
	double *eta;
	eta = malloc(parameterLength[2]*sizeof(double));
	double *swmax;
	swmax = malloc(parameterLength[3]*sizeof(double));
	double *lamdas;
	lamdas = malloc(parameterLength[4]*sizeof(double));
	double *lamdah;
	lamdah = malloc(parameterLength[5]*sizeof(double));
	double *rhomax;
	rhomax = malloc(parameterLength[6]*sizeof(double));
	double *f2;
	f2 = malloc(parameterLength[7]*sizeof(double));
	double *f1;
	f1 = malloc(parameterLength[8]*sizeof(double));
	double *gammac;
	gammac = malloc(parameterLength[9]*sizeof(double));
	double *gammax;
	gammax = malloc(parameterLength[10]*sizeof(double));
	double *cgl;
	cgl = malloc(parameterLength[11]*sizeof(double));
	double *cgr;
	cgr = malloc(parameterLength[12]*sizeof(double));
	double *cgw;
	cgw = malloc(parameterLength[13]*sizeof(double));
	double *deltal;
	deltal = malloc(parameterLength[14]*sizeof(double));
	double *deltar;
	deltar = malloc(parameterLength[15]*sizeof(double));
	double *sl;
	sl = malloc(parameterLength[16]*sizeof(double));

	double *sla;
	sla = malloc(parameterLength[17]*sizeof(double));
	// Rprintf("sla length: %i\n", parameterLength[17]);
	// Rprintf("sizeof double %i\n", sizeof(double));
	// Rprintf("sizeof sla %i\n", sizeof(sla));

	double *sr;
	sr = malloc(parameterLength[18]*sizeof(double));
	double *so;
	so = malloc(parameterLength[19]*sizeof(double));
	double *rr;
	rr = malloc(parameterLength[20]*sizeof(double));
	double *rhor;
	rhor = malloc(parameterLength[21]*sizeof(double));
	double *rml;
	rml = malloc(parameterLength[22]*sizeof(double));
	double *rms;
	rms = malloc(parameterLength[23]*sizeof(double));
	double *rmr;
	rmr = malloc(parameterLength[24]*sizeof(double));
	double *etaB;
	etaB = malloc(parameterLength[25]*sizeof(double));
	double *K;
	K = malloc(parameterLength[26]*sizeof(double));
	double *epsg;
	epsg = malloc(parameterLength[27]*sizeof(double));
	double *M;
	M = malloc(parameterLength[28]*sizeof(double));
	double *alpha;
	alpha = malloc(parameterLength[29]*sizeof(double));
	double *R0;
	R0 = malloc(parameterLength[30]*sizeof(double));
	double *R40;
	R40 = malloc(parameterLength[31]*sizeof(double));
	double *rhomin;
	rhomin = malloc(parameterLength[32]*sizeof(double));
	double *gammaw;
	gammaw = malloc(parameterLength[33]*sizeof(double));
	double *drinit;
	drinit = malloc(parameterLength[34]*sizeof(double));
	double *drcrit;
	drcrit = malloc(parameterLength[35]*sizeof(double));

	// for(int i=0; i < 36; i++){
	// 	Rprintf("value of index: %i value of parameterLength: %i\n", i, parameterLength[i]);
	// }

	for(int i=0; i < parameterLength[0]; i++){
		//Rprintf("i: %i\n", i);
		int index = startIndex[0] + i;
		//Rprintf("index: %i\n", index);
		hmax[i] = sparms2[index];
		//Rprintf("sparms2[index]: %g\n", sparms2[index]);
	}
	for(int i=0; i < parameterLength[1]; i++){
		int index = startIndex[1] + i;
		phih[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[2]; i++){
		int index = startIndex[2] + i;
		eta[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[3]; i++){
		int index = startIndex[3] + i;
		swmax[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[4]; i++){
		int index = startIndex[4] + i;
		lamdas[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[5]; i++){
		int index = startIndex[5] + i;
		lamdah[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[6]; i++){
		int index = startIndex[6] + i;
		rhomax[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[7]; i++){
		int index = startIndex[7] + i;
		f2[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[8]; i++){
		int index = startIndex[8] + i;
		f1[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[9]; i++){
		int index = startIndex[9] + i;
		gammac[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[10]; i++){
		int index = startIndex[10] + i;
		gammax[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[11]; i++){
		int index = startIndex[11] + i;
		cgl[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[12]; i++){
		int index = startIndex[12] + i;
		cgr[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[13]; i++){
		int index = startIndex[13] + i;
		cgw[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[14]; i++){
		int index = startIndex[14] + i;
		deltal[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[15]; i++){
		int index = startIndex[15] + i;
		deltar[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[16]; i++){
		int index = startIndex[16] + i;
		sl[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[17]; i++){
		int index = startIndex[17] + i;
		sla[i] = sparms2[index];
		// Rprintf("SLA value %i: %g\n", i, sla[i]);	
	}

	// Rprintf("sla length: %i\n", parameterLength[17]);
	// Rprintf("sizeof double %i\n", sizeof(double));
	// Rprintf("sizeof sla %i\n", sizeof(sla));

	for(int i=0; i < parameterLength[18]; i++){
		int index = startIndex[18] + i;
		sr[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[19]; i++){
		int index = startIndex[19] + i;
		so[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[20]; i++){
		int index = startIndex[20] + i;
		rr[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[21]; i++){
		int index = startIndex[21] + i;
		rhor[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[22]; i++){
		int index = startIndex[22] + i;
		rml[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[23]; i++){
		int index = startIndex[23] + i;
		rms[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[24]; i++){
		int index = startIndex[24] + i;
		rmr[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[25]; i++){
		int index = startIndex[25] + i;
		etaB[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[26]; i++){
		int index = startIndex[26] + i;
		K[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[27]; i++){
		int index = startIndex[27] + i;
		epsg[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[28]; i++){
		int index = startIndex[28] + i;
		M[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[29]; i++){
		int index = startIndex[29] + i;
		alpha[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[30]; i++){
		int index = startIndex[30] + i;
		R0[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[31]; i++){
		int index = startIndex[31] + i;
		R40[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[32]; i++){
		int index = startIndex[32] + i;
		rhomin[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[33]; i++){
		int index = startIndex[33] + i;
		gammaw[i] = sparms2[index];
	}
	for(int i=0; i < parameterLength[34]; i++){
		int index = startIndex[34] + i;
		drinit[i] = sparms2[index];
		// Rprintf("drinit value %i: %g\n", i, drinit[i]);	
	}
	for(int i=0; i < parameterLength[35]; i++){
		int index = startIndex[35] + i;
		drcrit[i] = sparms2[index];
		// Rprintf("drcrit value %i: %g\n", i, drcrit[i]);	
	}

	// NOTE: all indicies -1 because C starts at 0 while R starts at 1
	// Define p(plant) parameters based on R array
	///////////////////////////////////////////////////////////////////// TODO make sure to reactivate this 

	p.hmax = hmax[0];
	p.phih = phih[0];
	p.eta = eta[0];
	p.swmax = swmax[0]; //exp(-3.054);
	p.lamdas = lamdas[0];
	p.lamdah = lamdah[0];
	p.rhomax = rhomax[0]; //exp(13.2);
	// p.rhomin = rhomin[0]; //exp(13.2);
	p.rhomin = rhomin[0]; // this could be changed if rhomin != rhomax.
	p.f2 = f2[0]; //exp(8.456);//   //f2=gammax*NEWf2
	p.f1 = f1[0];
	p.gammac = gammac[0];
	p.gammaw = gammaw[0];
	p.gammax = gammax[0]; //inv_logit(-0.709);//
	p.cgl = cgl[0]; //exp(0.3229);//
	p.cgr = cgr[0]; //exp(0.192);//
	p.cgw = cgw[0]; //exp(0.3361);//
	p.deltal = deltal[0];//inv_logit(-2.276);//
	p.deltar = deltar[0]; //inv_logit(-2.832);//
	p.sl = sl[0]; //exp(0.8133);//
	p.sla = sla[0]; //exp(-4.119);//
	p.sr = sr[0]; //exp(0.2493);//
	p.so = so[0]; //exp(0.6336); //
	p.rr = rr[0]; //exp(-8.103); //
	p.rhor = rhor[0]; // new value: exp(-1.724);
	p.rml = rml[0]; //exp(2.544);//
	p.rms = rms[0]; //exp(0.5499); //
	p.rmr = rmr[0]; //exp(3.252);//
	p.etaB = etaB[0];
	p.K = K[0];
	p.epsg = epsg[0]; //exp(-3.304); //6.75;
	p.M = M[0];
	p.alpha = alpha[0];
	p.R0 = R0[0];
	p.R40 = R40[0];
	p.drinit = drinit[0];
	p.drcrit = drcrit[0];

	// define gp values based on input from R
	gp.deltat=gp2[0]; // gparm[1] <- 0.0625 # gp.deltat
	gp.T=gp2[1]; // gparm[2] <- 10 # gp.T length of run in years
	gp.tolerance=gp2[2]; // gparm[3] <- 0.00001 # gp.tolerance
	gp.BH=gp2[3]; // gparm[4] <- 1.37 # gp.BH
	//gp.Io=gp2[4];  // annual par APAR

	// Define a structure of forest parameters.
	Forestparms ForParms;
	ForParms.kF = *kF;
	ForParms.intF = *intF;
	ForParms.slopeF = *slopeF;

	/*
	The code in the following section is to facilitate transfer of
	parameter values to R.  It could be done more efficiently by
	updating the values in the above code but I decided not to modify
	the original code (MKF 4/7/2013).

	I modified the code to make it work better.  p and gp are structures
	passed to the growthloop function.  However; the rest are pointers.
	The pointers do not need to be dereferenced at this point since they
	already carry the addresses of what they point to.  This is the reason
	I also do not use & to send an address it is not necessary to send the
	address of something carrying an address.  At least that is how I think
	this is working (MKF 7/21/2014).
	*/
  // Hc and LAIF were added on 3/16/2018 by MKF to allow gap dynamics
  // simulations.
	growthloop(&p,&gp, Io, r0, t,
		Hc, LAIF, &ForParms, APARout,
		h,
		hh,
		hC,
		hB,
		hBH,
		r,
		rB,
		rC,
		rBH,
		sw,
		vts,
		vt,
		vth,
		sa,
		la,
		ra,
		dr,
		xa,
		bl,
		br,
		bt,
		bts,
		bth,
		boh,
		bos,
		bo,
		bs,

		cs,
		clr,
		fl,
		fr,
		ft,
		fo,
		rfl,
		rfr,
		rfs,

		egrow,
		ex,
		rtrans,
		light,
		nut,
		deltas,
		LAI,
		status,
		//i,
		//lenvars,
		errorind,
		growth_st,

		// Variables to replace p and allow temporally varying traits.
		hmax,
		phih,
		eta,
		swmax,
		lamdas,
		lamdah,
		rhomax,
		rhomin,
		f2,
		f1,
		gammac,
		gammaw,
		gammax,
		cgl,
		cgr,
		cgw,
		deltal,
		deltar,
		sl,
		sla,
		sr,
		so,
		rr,
		rhor,
		rml,
		rms,
		rmr,
		etaB,
		K,
		epsg,
		M,
		alpha,
		R0,
		R40,

		parameterLength
	//tolout,
	//errorout,
    //drout,
    //demandout,
    //odemandout,
    //odrout
	);

	// Make sure memory is freed before returning to R
	free(hmax);
	free(phih);
	free(eta);
	free(swmax);
	free(lamdas);
	free(lamdah);
	free(rhomax);
	free(f2);
	free(f1);
	free(gammac);
	free(gammax);
	free(cgl);
	free(cgr);
	free(cgw);
	free(deltal);
	free(deltar);
	free(sl);
	free(sla);
	free(sr);
	free(so);
	free(rr);
	free(rhor);
	free(rml);
	free(rms);
	free(rmr);
	free(etaB);
	free(K);
	free(epsg);
	free(M);
	free(alpha);
	free(R0);
	free(R40);
	free(rhomin);
	free(gammaw);
	free(drinit);
	free(drcrit);
} // End of Rgrowthloop






