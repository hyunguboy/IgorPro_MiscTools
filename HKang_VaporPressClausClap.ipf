#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.0

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.0 (Released 2020-07-08)
//	1.	Initial release tested with Igor Pro 6.37 and 8.04.

////////////////////////////////////////////////////////////////////////////////

//	Calculates the gas phase concentrations of compounds by using the
//	Clausius-Clapeyron equation.

////////////////////////////////////////////////////////////////////////////////

//	v_enthalpyVap:	kJ mol-1
//	v_refPressTorr:	Torr
//	v_currentTempK:	Kelvin
//	v_refTempK:		Kelvin
Function HKang_ClausiusClapeyron(v_enthalpyVap, v_refPressTorr, v_currentTempK, v_refTempK)
	Variable v_enthalpyVap, v_refPressTorr, v_currentTempK, v_refTempK

	Variable v_currentPressTorr
	Variable v_gasConstant = 0.008314 // kJ mol-1 K-1
	Variable v_ClausClapExponent

	v_ClausClapExponent = exp(-v_enthalpyVap/v_gasConstant * (1/v_currentTempK - 1/v_refTempK))

	v_currentPressTorr = v_refPressTorr * v_ClausClapExponent

	Return v_currentPressTorr

End

////////////////////////////////////////////////////////////////////////////////

Function HKang_TorrToPPB(v_currentPressTorr, v_ambientPressTorr)
	Variable v_currentPressTorr, v_ambientPressTorr

	Variable v_currentConcPPB

	v_currentConcPPB = v_currentPressTorr/v_ambientPressTorr * 1e9

	Return v_currentConcPPB

End

////////////////////////////////////////////////////////////////////////////////