#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.0

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.0 (Released 2020-06-10)
//	1.	Initial release tested with Igor Pro 6.37 and 8.04.

////////////////////////////////////////////////////////////////////////////////

//	Statistically unverified method of identifying outliers in a time series.
//	Use at your own risk.

////////////////////////////////////////////////////////////////////////////////

Function HKang_FindOutliers(w_conc, w_time)
	Wave w_conc, w_time

	Variable v_MSE // Mean squared error
	Variable p = 1 // Number of predictors in the regression. p = 1, since linear.
	Variable v_linFitAllSlope, v_linFitAllConst
	Variable iloop, jloop
	Variable v_starttime, v_endtime
	
	v_starttime = startMSTimer

	// Make the Y and X axis waves.
	Duplicate/O w_conc, w_RegY
	Duplicate/O w_conc, w_RegX

	InsertPoints/M=0 0, 1, w_RegY
	InsertPoints/M=0 numpnts(w_RegX), 1, w_RegX

	w_RegY[0] = NaN
	w_RegX[numpnts(w_RegX) - 1] = NaN

	// Make waves to calculate Cook's Distance statistics.
	Duplicate/O w_RegY, w_CooksD
	Duplicate/O w_RegY, w_linFitAll
	Make/O/D/N=(numpnts(w_RegY) - 1), w_linFitPntRmvd
	Duplicate/O w_RegY, w_SqrdErrAll
	Duplicate/O w_RegY, w_SqrdErrPntRmvd

	w_CooksD = NaN
	w_linFitAll = NaN
	w_linFitPntRmvd = NaN
	w_SqrdErrAll = NaN
	w_SqrdErrPntRmvd = NaN

	// Do a linear regression and get the mean square error	 with all the points.
	CurveFit/Q line, w_RegY/X=w_RegX/D=w_linFitAll
	
	Wave W_coef
	
	v_linFitAllConst = W_coef[0]
	v_linFitAllSlope = W_coef[1]
	
	For(iloop = 0; iloop < numpnts(w_RegY); iloop += 1)
		w_SqrdErrAll[iloop] = (w_RegY[iloop] - (v_linFitAllConst + v_linFitAllSlope * w_RegX[iloop]))^2
	EndFor
	
	WaveStats/Q w_SqrdErrAll
	
	v_MSE = V_sum/(numpnts(w_SqrdErrAll) - 2)

	// Calculate Cook's Distance.
	For(iloop = 0; iloop < numpnts(w_RegY); iloop += 1)
		Duplicate/O w_RegY, w_RegYPntRmvd
		Duplicate/O w_RegX, w_RegXPntRmvd

		DeletePoints/M=0 iloop, 1, w_RegYPntRmvd
		DeletePoints/M=0 iloop, 1, w_RegXPntRmvd
		
		CurveFit/Q line, w_RegYPntRmvd/X=w_RegXPntRmvd/D=w_linFitPntRmvd
		
		For(jloop = 0; jloop < numpnts(w_RegY); jloop += 1)
			w_SqrdErrPntRmvd[jloop] = ((v_linFitAllConst + v_linFitAllSlope * w_RegX[jloop]) - (W_coef[0] + W_coef[1] * w_RegX[jloop]))^2
		EndFor
		
		WaveStats/Q w_SqrdErrPntRmvd
		
		w_CooksD[iloop] = V_sum/(p * v_MSE)
	EndFor

	v_endtime = stopMSTimer(1)
	
	print v_endtime/1e6
	
End







