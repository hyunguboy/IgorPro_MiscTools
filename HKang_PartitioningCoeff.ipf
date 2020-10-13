#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.0 (Released 2020-10-13)
//	1.	Initial release tested with Igor Pro 8.04.

////////////////////////////////////////////////////////////////////////////////

//	'HKang_ParitioningCoeff' calculates the fraction of some organic compound
//	in the gas and particle phases at a designated organic aerosol mass
//	loading. The gas and particle fractions are on the Y-axis, while the
//	organic aerosol mass is on the X-axis. Please refer to the following paper
//	for additional explanations and equations.
//
//	"Coupled Partitioning, Dilution, and Chemical Aging of Semivolatile
//	Organics", Donahue et al. (2006, Environ. Sci. Tech.)
//	https://pubs.acs.org/doi/10.1021/es052297c

////////////////////////////////////////////////////////////////////////////////

Function HKang_ParitioningCoeff(v_M, v_vapPress, v_maxOA)
	Variable v_M // molecular molar weight (g mol-1)
	Variable v_vapPress // vapor pressure at 25C (torr)
	Variable v_maxOA // maximum OA mass for the X-axis (ug m-3)

	Variable iloop
	Variable v_numpnts = v_maxOA/5 // number of points on the X-axis.
	Variable v_Cstar // effective saturation concentration (ug m-3)
	Variable v_Zeta = 1 // activity coefficient
	Variable v_R = 0.062363 // gas constant (m3 torr K-1 mol-1)
	Variable v_T = 298 // ambient temperature (K)

	v_Cstar = (v_M * 1e6 * v_Zeta * v_vapPress)/(760 * v_R * v_T)

	Make/O/D/N=(v_numpnts) w_Coa = NaN
	Make/O/D/N=(v_numpnts) w_Fp = NaN
	Make/O/D/N=(v_numpnts) w_FpGas = NaN

	For(iloop = 0; iloop < v_numpnts; iloop += 1)
		w_Coa[iloop] = 0.001 + (v_maxOA - 0.001)/(v_numpnts - 1) * iloop
	
		w_Fp[iloop] = 1/(1+v_Cstar/w_Coa[iloop])
		w_FpGas[iloop] = 1 - w_Fp[iloop]
	EndFor

	// Display generated waves.
	Display/K=1 w_Fp vs w_Coa
	AppendToGraph w_FpGas vs w_Coa; DelayUpdate

	ModifyGraph log(bottom)=1; DelayUpdate
	Label left "Partitioning Coefficient (mass fraction in particle phase)"; DelayUpdate
	Label bottom "C\\BOA\\M (μg/m\\S3\\M)"; DelayUpdate
	ModifyGraph lsize=2; DelayUpdate
	ModifyGraph rgb(w_Fp)=(0,0,65535); DelayUpdate
	Legend/C/N=text0/J/F=0/A=MC "\\s(w_Fp) Particle\r\\s(w_FpGas) Gas"; DelayUpdate

End