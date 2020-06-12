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

Function HKang_MasterOutliersRun(w_conc, w_time)
	Wave w_conc, w_time
	
	HKang_FindOutliersCooksD(w_conc, w_time)
	
	HKang_GetOutliers(w_conc, w_time)
	
	HKang_DisplayOutliers(w_conc, w_time)

End

////////////////////////////////////////////////////////////////////////////////

Function HKang_FindOutliersCooksD(w_conc, w_time)
	Wave w_conc, w_time

	Variable v_MSE // Mean squared error
	Variable p = 1 // Number of predictors in the regression. p = 1, since linear.
	Variable v_linFitAllSlope, v_linFitAllConst
	Variable iloop, jloop
	Variable v_starttime, v_endtime

	Print "Starting at: " + time()
	v_starttime = startMSTimer

	// Make the Y and X axis waves.
	Duplicate/O w_conc, w_RegY
	Duplicate/O w_conc, w_RegX

	DeletePoints/M=0 0, 1, w_RegY
	InsertPoints/M=0 numpnts(w_RegY), 1, w_RegY

	w_RegY[numpnts(w_RegY) - 1] = NaN

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

	v_MSE = V_sum/(V_npnts - V_numNans)

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

	v_endtime = stopMSTimer(v_starttime)

	Print "Ended calculation at: " + time()
	Print "Total calculation time (sec): ", v_endtime/1e6

End

////////////////////////////////////////////////////////////////////////////////

Function HKang_GetOutliers(w_conc, w_time)
	Wave w_conc, w_time

	Wave w_RegY, w_RegX, w_CooksD

	Duplicate/O w_RegY, w_RegYOutlrsRmvd
	Duplicate/O w_RegX, w_RegXOutlrsRmvd

	Make/O/D/N=0 w_RegYOutlrs
	Make/O/D/N=0 w_RegXOutlrs
	Make/O/D/N=0 w_timeOutlrs

	Variable v_npntsRemoved = 0
	Variable/G v_CooksDLimit
	Variable iloop

	v_CooksDLimit = 3 * mean(w_CooksD)

	For(iloop = 0; iloop < numpnts(w_RegY); iloop += 1)

		If(w_CooksD[iloop] > v_CooksDLimit)
			w_RegYOutlrsRmvd[iloop] = NaN
			w_RegXOutlrsRmvd[iloop] = NaN

			InsertPoints/M=0 numpnts(w_RegYOutlrs), 1, w_RegYOutlrs
			InsertPoints/M=0 numpnts(w_RegXOutlrs), 1, w_RegXOutlrs
			InsertPoints/M=0 numpnts(w_timeOutlrs), 1, w_timeOutlrs

			w_RegYOutlrs[numpnts(w_RegYOutlrs) - 1] = w_RegY[iloop]
			w_RegXOutlrs[numpnts(w_RegXOutlrs) - 1] = w_RegX[iloop]
			w_timeOutlrs[numpnts(w_timeOutlrs) - 1] = w_time[iloop]

			v_npntsRemoved += 1
		EndIf

	EndFor

	Print "Number of possible Outliers: ", v_npntsRemoved
	Print "Mean CooksD: ", mean(w_CooksD)
	Print "Calculated CooksD limit for outliers: ", v_CooksDLimit

End

////////////////////////////////////////////////////////////////////////////////

Function HKang_DisplayOutliers(w_conc, w_time)
	Wave w_conc, w_time
	
	Wave w_RegY, w_RegX
	Wave w_RegYOutlrsRmvd, w_RegXOutlrsRmvd
	Wave w_RegYOutlrs, w_RegXOutlrs, w_timeOutlrs
	Wave w_CooksD
	
	Display/K=1 w_cooksD vs w_conc
	ModifyGraph mode=3; DelayUpdate
	Label left "Cook's Distance Score"; DelayUpdate
	Label bottom "Concentration (w_RegX)"; DelayUpdate

	Display/K=1 w_conc vs w_time
	ModifyGraph rgb=(0,0,0); DelayUpdate
	AppendToGraph w_RegXOutlrs vs w_timeOutlrs; DelayUpdate
	ModifyGraph mode(w_RegXOutlrs)=3,marker(w_RegXOutlrs)=8,mrkThick(w_RegXOutlrs)=1; DelayUpdate
	Legend/C/N=text0/A=MC
	Label left "Concentration";DelayUpdate
	Label bottom "Date & Time"

	Display/K=1 w_RegY vs w_RegX
	ModifyGraph mode=3,rgb=(0,0,0); DelayUpdate
	AppendToGraph w_RegYOutlrs vs w_RegXOutlrs; DelayUpdate
	ModifyGraph mode=3,marker(w_RegYOutlrs)=8; DelayUpdate
	Legend/C/N=text0/A=MC; DelayUpdate
	Label left "x+1 (w_RegY)";DelayUpdate
	Label bottom "x (w_RegX)"; DelayUpdate

End