#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function HKang_LazyOutlierFinder(w_conc, w_time)
	Wave w_conc, w_time

	Duplicate/O w_conc, w_RegY
	Duplicate/O w_conc, w_RegX

	InsertPoints/M=0 0, 1, w_RegY
	InsertPoints/M=0 numpnts(w_RegX), 1, w_RegX

	w_RegY[0] = NaN
	w_RegX[numpnts(w_RegX) - 1] = NaN

	Duplicate/O w_RegY, w_DistRegLineParallel
	Duplicate/O w_RegY, w_DistRegLinePerpendicular

	w_DistRegLineParallel = NaN
	w_DistRegLinePerpendicular = NaN














End