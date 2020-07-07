#pragma rtGlobals=3		// Use modern global access method and strict wave access.















Function HKang_ClausiusClapeyron(v_enthalpyVap, v_refPressTorr, v_currentTempK, v_refTempK)
	Variable v_enthalpyVap, v_refPressTorr, v_currentTempK, v_refTempK
	
	Variable v_currentPressTorr
	Variable v_gasConstant = 0.008314 // kJ mol-1 K-1
	
	v_currentPressTorr = v_refPressTorr * exp(-v_enthalpyVap/v_gasConstant * (1/v_currentTempK - 1/v_refTempK))
	
	Print v_currentPressTorr
	
End