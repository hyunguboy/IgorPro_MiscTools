#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.






Function HKang_WilliamsonYorkNoError(w_X, w_Y)
	Wave w_X, w_Y




End







Function HKang_WilliamsonYorkWithError(w_X, w_Y, w_sigmaX, w_sigmaY)
	Wave w_X, w_Y, w_sigmaX, w_sigmaY

















End








Function HKang_PearsonCorrCoeff(w_X, w_Y)
	Wave w_X, w_Y
	
	Variable v_pearson
	Variable v_numerator
	Variable v_denominator

	Duplicate/O/D w_X, w_XtimesX
	Duplicate/O/D w_X, w_YtimesY
	Duplicate/O/D w_X, w_XtimesY

	w_XtimesX = w_X * w_X
	w_YtimesY = w_Y * w_Y
	w_XtimesY = w_X * w_Y

	v_numerator = numpnts(w_X) * sum(w_XtimesY) - sum(w_X) * sum(w_Y)
	



End
























