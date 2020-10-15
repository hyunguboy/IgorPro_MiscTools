#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.1 (Released 2020-10-15)
//	1.	The points for the X-axis on the log10 plot are now evenly spaced.
//		Previously, the uneven spacing would cause the curves on the plot
//		to look jagged.
//	2.	Error messages have been added for user convenience.
//
//	Version 1.0 (Released 2020-10-13)
//	1.	Initial release tested with Igor Pro 8.04.

////////////////////////////////////////////////////////////////////////////////

//	'HKang_ParitioningCoeffSatConc' calculates the fraction of some organic
//	compound in the gas and particle phases at a designated organic aerosol
//	mass loading. The gas and particle fractions are on the Y-axis, while the
//	organic aerosol mass is on the X-axis. Please refer to the following paper
//	for additional explanations and equations.
//
//	"Coupled Partitioning, Dilution, and Chemical Aging of Semivolatile
//	Organics", Donahue et al. (2006, Environ. Sci. Tech.)
//	https://pubs.acs.org/doi/10.1021/es052297c
//
//	'HKang_ParitioningCoeffMassLoad' is the same as above, except that the
//	saturation concentration is on the Y-axis and the mass loading is an
//	input value.
//
//	alpha-pinene: 4.75 mmHg, 136 g/mol (Pubchem)
//	oleic acid: 1.3e-6 mmHg, 282 g/mol (Pubchem)
//	pinic acid: 9e-4 mmHg, 186 g/mol (Reference below)
//	pinonic acid: 7e-3 mmHg, 184 g/mol (Reference below)
//
//	"Gas chromatographic vapor pressure determination of atmospherically 
//	relevant oxidation products of β-caryophyllene and α-pinene",
//	Hartonen et al. (2013, Atmos. Environ.)
//	https://www.sciencedirect.com/science/article/abs/pii/S1352231013007115

////////////////////////////////////////////////////////////////////////////////

Function HKang_ParitioningCoeffSatConc(v_M, v_vapPress, v_minOA, v_maxOA)
	Variable v_M // molecular molar weight (g mol-1)
	Variable v_vapPress // vapor pressure at 25C (torr)
	Variable v_minOA // minimum OA mass for the X-axis (ug m-3)
	Variable v_maxOA // maximum OA mass for the X-axis (ug m-3)

	Variable iloop
	Variable v_numpnts = 500 // number of points on the X-axis.
	Variable v_Cstar // effective saturation concentration (ug m-3)
	Variable v_Zeta = 1 // activity coefficient
	Variable v_R = 0.062363 // gas constant (m3 torr K-1 mol-1)
	Variable v_T = 298 // ambient temperature (K)

	// Error messages.
	If(v_minOA <=0)
		Print "Aborting: v_minOA must be a non-zero positive number."
		Abort "Aborting: v_minOA must be a non-zero positive number."
	EndIf

	If(v_minOA >= v_maxOA)
		Print "Aborting: v_maxOA must larger than v_minOA."
		Abort "Aborting: v_maxOA must larger than v_minOA."
	EndIf

	v_Cstar = (v_M * 1e6 * v_Zeta * v_vapPress)/(760 * v_R * v_T)

	// Make waves to be displayed.
	Make/O/D/N=(v_numpnts) w_CoaLin = NaN
	Make/O/D/N=(v_numpnts) w_CoaLog = NaN

	Make/O/D/N=(v_numpnts) w_FpLin = NaN
	Make/O/D/N=(v_numpnts) w_FpLog = NaN
	Make/O/D/N=(v_numpnts) w_FpGasLin = NaN
	Make/O/D/N=(v_numpnts) w_FpGasLog = NaN

	For(iloop = 0; iloop < v_numpnts; iloop += 1)
		w_CoaLin[iloop] = v_minOA + iloop * (v_maxOA - v_minOA)/(v_numpnts - 1)
		w_FpLin[iloop] = 1/(1 + v_Cstar/w_CoaLin[iloop])
		w_FpGasLin[iloop] = 1 - w_FpLin[iloop]

		w_CoaLog[iloop] = 10^(log(v_minOA) + iloop * (log(v_maxOA) - log(v_minOA))/(v_numpnts - 1))
		w_FpLog[iloop] = 1/(1 + v_Cstar/w_CoaLog[iloop])
		w_FpGasLog[iloop] = 1 - w_FpLog[iloop]		
	EndFor

	// Display generated waves, both log10 and linear X-axes.
	Display/K=1 w_FpLog vs w_CoaLog
	AppendToGraph w_FpGasLog vs w_CoaLog; DelayUpdate

	ModifyGraph log(bottom)=1; DelayUpdate
	Label left "Partitioning Coefficient\r(Mass fraction in particle phase)"; DelayUpdate
	Label bottom "C\\BOA\\M (μg/m\\S3\\M)"; DelayUpdate
	ModifyGraph lsize=2; DelayUpdate
	ModifyGraph rgb(w_FpLog)=(0,0,65535); DelayUpdate
	Legend/C/N=text0/J/F=0/A=MC "\\s(w_FpLog) Particle\r\\s(w_FpGasLog) Gas"; DelayUpdate

	Display/K=1 w_FpLin vs w_CoaLin
	AppendToGraph w_FpGasLin vs w_CoaLin; DelayUpdate

	Label left "Partitioning Coefficient\r(Mass fraction in particle phase)"; DelayUpdate
	Label bottom "C\\BOA\\M (μg/m\\S3\\M)"; DelayUpdate
	ModifyGraph lsize=2; DelayUpdate
	ModifyGraph rgb(w_FpLin)=(0,0,65535); DelayUpdate
	Legend/C/N=text0/J/F=0/A=MC "\\s(w_FpLin) Particle\r\\s(w_FpGasLin) Gas"; DelayUpdate

End

////////////////////////////////////////////////////////////////////////////////

Function HKang_ParitioningCoeffMassLoad(v_M, v_Coa, v_minCstar, v_maxCstar)
	Variable v_M // molecular molar weight (g mol-1)
	Variable v_Coa // mass loading (ug m-3)
	Variable v_minCstar // minimum OA mass for the X-axis (ug m-3)
	Variable v_maxCstar // maximum OA mass for the X-axis (ug m-3)

	Variable iloop
	Variable v_numpnts = 500 // number of points on the X-axis.
	Variable v_Zeta = 1 // activity coefficient
	Variable v_R = 0.062363 // gas constant (m3 torr K-1 mol-1)
	Variable v_T = 298 // ambient temperature (K)

	// Error messages.
	If(v_minCstar <=0)
		Print "Aborting: v_minCstar must be a non-zero positive number."
		Abort "Aborting: v_minCstar must be a non-zero positive number."
	EndIf

	If(v_minCstar >= v_maxCstar)
		Print "Aborting: v_maxCstar must larger than v_minOA."
		Abort "Aborting: v_maxCstar must larger than v_minOA."
	EndIf

	// Make waves to be displayed.
	Make/O/D/N=(v_numpnts) w_CstarLin = NaN
	Make/O/D/N=(v_numpnts) w_CstarLog = NaN

	Make/O/D/N=(v_numpnts) w_FpLin = NaN
	Make/O/D/N=(v_numpnts) w_FpLog = NaN
	Make/O/D/N=(v_numpnts) w_FpGasLin = NaN
	Make/O/D/N=(v_numpnts) w_FpGasLog = NaN

	For(iloop = 0; iloop < v_numpnts; iloop += 1)
		w_CstarLin[iloop] = v_minCstar + iloop * (v_maxCstar - v_minCstar)/(v_numpnts - 1)
		w_FpLin[iloop] = 1/(1 + w_CstarLin[iloop]/v_Coa)
		w_FpGasLin[iloop] = 1 - w_FpLin[iloop]

		w_CstarLog[iloop] = 10^(log(v_minCstar) + iloop * (log(v_maxCstar) - log(v_minCstar))/(v_numpnts - 1))
		w_FpLog[iloop] = 1/(1 + w_CstarLog[iloop]/v_Coa)
		w_FpGasLog[iloop] = 1 - w_FpLog[iloop]		
	EndFor

	// Display generated waves, both log10 and linear X-axes.
	Display/K=1 w_FpLog vs w_CstarLog
	AppendToGraph w_FpGasLog vs w_CstarLog; DelayUpdate

	ModifyGraph log(bottom)=1; DelayUpdate
	Label left "Partitioning Coefficient\r(Mass fraction in particle phase)"; DelayUpdate
	Label bottom "C* (μg/m\\S3\\M)"; DelayUpdate
	ModifyGraph lsize=2; DelayUpdate
	ModifyGraph rgb(w_FpLog)=(0,0,65535); DelayUpdate
	Legend/C/N=text0/J/F=0/A=MC "\\s(w_FpLog) Particle\r\\s(w_FpGasLog) Gas"; DelayUpdate
	TextBox/C/N=text1/F=0/A=MC "C\\BOA\\M = " + num2str(v_Coa) + " μg/m\\S3\\M"; DelayUpdate

	Display/K=1 w_FpLin vs w_CstarLin
	AppendToGraph w_FpGasLin vs w_CstarLin; DelayUpdate

	Label left "Partitioning Coefficient\r(Mass fraction in particle phase)"; DelayUpdate
	Label bottom "C* (μg/m\\S3\\M)"; DelayUpdate
	ModifyGraph lsize=2; DelayUpdate
	ModifyGraph rgb(w_FpLin)=(0,0,65535); DelayUpdate
	Legend/C/N=text0/J/F=0/A=MC "\\s(w_FpLin) Particle\r\\s(w_FpGasLin) Gas"; DelayUpdate
	TextBox/C/N=text1/F=0/A=MC "C\\BOA\\M = " + num2str(v_Coa) + " μg/m\\S3\\M"; DelayUpdate

End