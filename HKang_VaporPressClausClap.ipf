#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.0

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.0 (Released 2020-07-22)
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

//	'w_inputValues' needs to have the following values in order:
//	1.	v_enthalpyVap:		kJ mol-1
//	2.	v_refPressTorr:		Torr
//	3.	v_ambientPressTorr:	Torr
//	4.	v_refTempK:			Kelvin
Function HKang_PlotPPBvsTempK(w_inputValues, v_lowerTempK, v_upperTempK)
	Wave w_inputValues
	Variable v_lowerTempK, v_upperTempK

	Variable v_enthalpyVap = w_inputValues[0]
	Variable v_refPressTorr = w_inputValues[1]
	Variable v_ambientPressTorr = w_inputValues[2]
	Variable v_refTempK = w_inputValues[3]
	Variable v_currentPressTorr
	Variable v_plotNumpnts = 300 // Number of points on the generated figure.
	Variable iloop

	Make/O/D/N=(v_plotNumpnts) w_X_tempK
	Make/O/D/N=(v_plotNumpnts) w_Y_ConcPPB

	For(iloop = 0; iloop < v_plotNumpnts; iloop += 1)
		w_X_tempK[iloop] = v_lowerTempK + iloop * (v_upperTempK - v_lowerTempK)/v_plotNumpnts

		v_currentPressTorr = HKang_ClausiusClapeyron(v_enthalpyVap, v_refPressTorr, w_X_tempK[iloop], v_refTempK)

		w_Y_ConcPPB[iloop] = HKang_TorrToPPB(v_currentPressTorr, v_ambientPressTorr)
	EndFor

	// Display figure.
	Display/K=1 w_Y_ConcPPB vs w_X_tempK
	ModifyGraph standoff=0; DelayUpdate
	Label left "Concentration (ppb)"; DelayUpdate
	Label bottom "Temperature (K)"; DelayUpdate
	ModifyGraph lsize=2,rgb=(0,0,0); DelayUpdate

End



















