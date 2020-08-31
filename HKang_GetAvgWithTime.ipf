#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.0

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.1 (Released 2020-08-31)
//	1.	Minor grammar error fixes.
//
//	Version 1.0 (Released 2020-06-24)
//	1.	Initial release tested with Igor Pro 6.37 and 8.04.

////////////////////////////////////////////////////////////////////////////////

//	'HKang_GetAvgWithTime' takes a time series concentration wave, its
//	corresponding time wave, and time points and prints the mean and faverage
//	of the concentrations in the input time points.

////////////////////////////////////////////////////////////////////////////////

//	str_startTime, str_endTime need to be in the format of "YYYY-MM-DD HH:MM:SS".
//	The start and end time points need to exist in w_time.
Function HKang_GetAvgWithTime(w_conc, w_time, str_startTime, str_endTime)
	Wave w_conc, w_time
	String str_startTime, str_endTime

	Variable v_startYear, v_startMonth, v_startDay
	Variable v_startHour, v_startMinute, v_startSecond
	Variable v_endYear, v_endMonth, v_endDay
	Variable v_endHour, v_endMinute, v_endSecond
	Variable v_startTime, v_endTime
	Variable v_startPoint, v_endPoint
	Variable v_concMean, v_concFaverage
	Variable iloop

	DFREF dfr_current = GetDataFolderDFR()

	// Check that the time and concentration wave lengths are of the same length.
	If(numpnts(w_time) != numpnts(w_conc))
		Print "Aborting: Time and concentration waves have different lengths."
		Abort "Aborting: Time and concentration waves have different lengths."
	EndIf	

	// Convert the input time strings into numbers.
	sscanf str_startTime, "%d-%d-%d %d:%d:%d", v_startYear, v_startMonth, v_startDay, v_startHour, v_startMinute, v_startSecond
	sscanf str_endTime, "%d-%d-%d %d:%d:%d", v_endYear, v_endMonth, v_endDay, v_endHour, v_endMinute, v_endSecond

	v_startTime = date2secs(v_startYear, v_startMonth, v_startDay) + v_startHour * 3600 + v_startMinute * 60 + v_startSecond
	v_endTime = date2secs(v_endYear, v_endMonth, v_endDay) + v_endHour * 3600 + v_endMinute * 60 + v_endSecond

	// Check that the end time is larger than the start time.
	If(v_startTime >= v_endTime)
		Print "Aborting: End time is not larger than start time."
		Abort "Aborting: End time is not larger than start time."
	EndIf

	// Find point numbers for the input times.
	FindValue/V=(v_startTime) w_time
	v_startPoint = V_value
	FindValue/V=(v_endTime) w_time
	v_endPoint = V_value

	// Check if w_conc contains NaN in the time range.
	WaveStats/Q/R=[v_startPoint, v_endPoint] w_conc

	// Create a temporary wave if w_conc contains NaN.
	If(V_numNans != 0)
		Make/O/D/N=0 w_getAvgTempConc
		Make/O/D/N=0 w_getAvgTempTime

		For(iloop = v_startPoint; iloop < v_endPoint; iloop += 1)
			If(numtype(w_conc[iloop]) == 0)
				InsertPoints/M=0 numpnts(w_getAvgTempConc), 1, w_getAvgTempConc
				InsertPoints/M=0 numpnts(w_getAvgTempTime), 1, w_getAvgTempTime

				w_getAvgTempConc[numpnts(w_getAvgTempConc) - 1] = w_conc[iloop]
				w_getAvgTempTime[numpnts(w_getAvgTempTime) - 1] = w_time[iloop]
			EndIf
		EndFor

		v_concMean = mean(w_getAvgTempConc)
		v_concFaverage = faverageXY(w_getAvgTempTime, w_getAvgTempConc)
	Else
		v_concMean = mean(w_conc, v_startTime, v_endTime)
		v_concFaverage = faverageXY(w_time, w_conc, v_startTime, v_endTime)
	EndIf

	Print "Number of NaNs in input range of " + nameofwave(w_conc) + ": ", V_numNans
	Print "Mean: ", v_concMean
	Print "faverage: ", v_concFaverage

	SetDataFolder dfr_current

End