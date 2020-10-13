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
//
//	alpha-pinene: 4.75 mmHg, 136 g/mol (Pubchem)
//	oleic acid: 1.3e-6 mmHg, 282 g/mol (Pubchem)
//	pinic acid: 9e-4 mmHg, 186 g/mol (Reference below)
//	pinonic acid: 7e-3, 184 g/mol (Reference below)
//
//	"Gas chromatographic vapor pressure determination of atmospherically 
//	relevant oxidation products of β-caryophyllene and α-pinene",
//	Hartonen et al. (2013, Atmos. Environ.)
//	https://www.sciencedirect.com/science/article/abs/pii/S1352231013007115

////////////////////////////////////////////////////////////////////////////////

Function HKang_ParitioningCoeff(v_M, v_vapPress, v_maxOA)
	Variable v_M // molecular molar weight (g mol-1)
	Variable v_vapPress // vapor pressure at 25C (torr)
	Variable v_maxOA // maximum OA mass for the X-axis (ug m-3)

	Variable iloop
	Variable v_numpnts = 200 // number of points on the X-axis.
	Variable v_Cstar // effective saturation concentration (ug m-3)
	Variable v_Zeta = 1 // activity coefficient
	Variable v_R = 0.062363 // gas constant (m3 torr K-1 mol-1)
	Variable v_T = 298 // ambient temperature (K)

	v_Cstar = (v_M * 1e6 * v_Zeta * v_vapPress)/(760 * v_R * v_T)

	// Make waves to be displayed.
	Make/O/D/N=(v_numpnts) w_CoaLin = NaN
	Make/O/D/N=(v_numpnts) w_CoaLog = NaN
	Make/O/D/N=(v_numpnts) w_FpLin = NaN
	Make/O/D/N=(v_numpnts) w_FpLog = NaN
	Make/O/D/N=(v_numpnts) w_FpGasLin = NaN
	Make/O/D/N=(v_numpnts) w_FpGasLog = NaN

	For(iloop = 0; iloop < v_numpnts; iloop += 1)
		w_CoaLin[iloop] = 0.01 + iloop * (v_maxOA - 0.001)/(v_numpnts - 1)
		w_FpLin[iloop] = 1/(1+v_Cstar/w_CoaLin[iloop])
		w_FpGasLin[iloop] = 1 - w_FpLin[iloop]

		w_CoaLog[iloop] = 0.01 + 10^(iloop * (log(v_maxOA + 1))/(v_numpnts - 1)) - 1
		w_FpLog[iloop] = 1/(1+v_Cstar/w_CoaLog[iloop])
		w_FpGasLog[iloop] = 1 - w_FpLog[iloop]		
	EndFor

	// Display generated waves, both log10 and linear X-axes.
	Display/K=1 w_FpLog vs w_CoaLog
	AppendToGraph w_FpGasLog vs w_CoaLog; DelayUpdate

	ModifyGraph log(bottom)=1; DelayUpdate
	Label left "Partitioning Coefficient (mass fraction in particle phase)"; DelayUpdate
	Label bottom "C\\BOA\\M (μg/m\\S3\\M)"; DelayUpdate
	ModifyGraph lsize=2; DelayUpdate
	ModifyGraph rgb(w_FpLog)=(0,0,65535); DelayUpdate
	Legend/C/N=text0/J/F=0/A=MC "\\s(w_FpLog) Particle\r\\s(w_FpGasLog) Gas"; DelayUpdate

	Display/K=1 w_FpLin vs w_CoaLin
	AppendToGraph w_FpGasLin vs w_CoaLin; DelayUpdate

	Label left "Partitioning Coefficient (mass fraction in particle phase)"; DelayUpdate
	Label bottom "C\\BOA\\M (μg/m\\S3\\M)"; DelayUpdate
	ModifyGraph lsize=2; DelayUpdate
	ModifyGraph rgb(w_FpLin)=(0,0,65535); DelayUpdate
	Legend/C/N=text0/J/F=0/A=MC "\\s(w_FpLin) Particle\r\\s(w_FpGasLin) Gas"; DelayUpdate

End