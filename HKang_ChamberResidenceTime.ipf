#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.1

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.0 (Released 2020-10-06)
//	1.	Initial release tested with Igor Pro 8.04.

////////////////////////////////////////////////////////////////////////////////

//	'HKang_ChamberResidenceTime' calculates the first-order decay of some
//	species in a chamber and plots the concentration vs time.

////////////////////////////////////////////////////////////////////////////////

Function HKang_ChamberResidenceTime(v_volume, v_flowRate, v_initConc, v_modelTime)
	Variable v_volume		// Volume of chamber in liters.
	Variable v_flowRate		// Flow rate through chamber in L min-1.
	Variable v_initConc		// Initial concentration. Units arbitrary.
	Variable v_modelTime	// The length of the X-axis for the figure in minutes.

	Variable iloop
	Variable v_flushRate = v_flowRate/v_volume

	Make/O/D/N=1000 w_modelTimeMin = NaN
	Make/O/D/N=1000 w_modelTimeHour = NaN
	Make/O/D/N=1000 w_modelConc = NaN

	For(iloop = 0; iloop < numpnts(w_modelConc); iloop += 1)
		w_modelTimeMin[iloop] = iloop * v_modelTime/(numpnts(w_modelConc)-1)
		w_modelTimeHour[iloop] = w_modelTimeMin[iloop]/60
		w_modelConc[iloop] = v_initConc * e^(-v_flushRate * w_modelTimeMin[iloop])
	EndFor
	
	Display/K=1 w_modelConc vs w_modelTimeMin
	AppendToGraph/B=Hour w_modelConc vs w_modelTimeHour

	ModifyGraph lsize(w_modelConc)=2; DelayUpdate
	ModifyGraph hideTrace(w_modelConc#1)=2; DelayUpdate
	ModifyGraph standoff=0; DelayUpdate
	ModifyGraph margin(bottom)=108; DelayUpdate
	ModifyGraph freePos(Hour)=50; DelayUpdate
	ModifyGraph lblPosMode(bottom)=1,lblPosMode(Hour)=1; DelayUpdate
	ModifyGraph lblMargin(bottom)=70,lblMargin(Hour)=20,lblPos(bottom)=0; DelayUpdate
	ModifyGraph nticks(Hour)=8; DelayUpdate
	SetAxis left 0,*; DelayUpdate
	Label left "Concentration"; DelayUpdate
	Label bottom "Flush time (min)"; DelayUpdate
	Label Hour "Flush time (hour)"; DelayUpdate

	Display/K=1 w_modelConc vs w_modelTimeMin
	AppendToGraph/B=Hour w_modelConc vs w_modelTimeHour

	ModifyGraph log(left)=1;DelayUpdate
	ModifyGraph lsize(w_modelConc)=2; DelayUpdate
	ModifyGraph hideTrace(w_modelConc#1)=2; DelayUpdate
	ModifyGraph standoff=0; DelayUpdate
	ModifyGraph margin(bottom)=108; DelayUpdate
	ModifyGraph freePos(Hour)=50; DelayUpdate
	ModifyGraph lblPosMode(bottom)=1,lblPosMode(Hour)=1; DelayUpdate
	ModifyGraph lblMargin(bottom)=70,lblMargin(Hour)=20,lblPos(bottom)=0; DelayUpdate
	ModifyGraph nticks(Hour)=8; DelayUpdate
	SetAxis/A left; DelayUpdate
	Label left "Concentration"; DelayUpdate
	Label bottom "Flush time (min)"; DelayUpdate
	Label Hour "Flush time (hour)"; DelayUpdate

End