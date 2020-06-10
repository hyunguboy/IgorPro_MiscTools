#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.1

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.1 (Released 2020-06-10)
//	1.	Minor adjustments to code syntax for better consistency.
//
//	Version 1.0 (Released 2020-06-04)
//	1.	Initial release tested with Igor Pro 6.37 and 8.04.

////////////////////////////////////////////////////////////////////////////////

//	HKang_ConvertToNaNPeriod: a function where you can input a time
//	starting and end point and a time series wave so that you can convert the
//	concentration values to NaN.

////////////////////////////////////////////////////////////////////////////////

//	Converts conventration values to NaN for an input time period in case
//	there is a reason instrument values need to be removed. The converted points
//	are those larger than s_startTime and equal or less than s_endTime.
//	Input times need to be in the format of "YYYY-MM-DD HH:MM:SS".
Function HKang_ConvertToNaNPeriod(w_conc, w_time, str_startTime, str_endTime)
	Wave w_conc, w_time
	String str_startTime, str_endTime

	Variable v_startYear, v_startMonth, v_startDay
	Variable v_startHour, v_startMinute, v_startSecond
	Variable v_endYear, v_endMonth, v_endDay
	Variable v_endHour, v_endMinute, v_endSecond
	Variable v_startTime, v_endTime
	Variable v_pointsConverted = 0
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

	// Convert the concentration points into NaN.
	For(iloop = 0; iloop < numpnts(w_time); iloop += 1)
		If(w_time[iloop] > v_startTime && w_time[iloop] <= v_endTime)
			w_conc[iloop] = NaN

			v_pointsConverted = v_pointsConverted + 1
		EndIf
	EndFor

	Print "Number of points removed from " + nameofwave(w_conc) + ": ", v_pointsConverted

	SetDataFolder dfr_current

End