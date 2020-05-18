#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 1.3

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.3 (Released 2020-05-18)
//	1.	Changed print output in case there are no recommended flow rates.
//	2.	Fixed bug where flow rate range on x-axis did not match the maximum
//		flow rate input.
//
//	Version 1.2 (Released 2020-05-14)
//	1.	Prints recommended flow rate range. See description for the conditions.
//
//	Version 1.1 (Released 2020-05-08)
//	1.	Added pressure differential calculation (using Hagen-Poiseuille).
//	2.	Changed line shapes on graph for black-and-white printers.
//	3.	Added more descriptive comments.
//
//	Version 1.0 (Released 2020-05-03)
//	1.	Initial release tested with Igor Pro 6.37 and 8.04.

////////////////////////////////////////////////////////////////////////////////

//	The function calculates the Reynolds number, residence time, and pressure
//	differential at the ends of the inlet. The function also prints a range
//	of flow rates that meets the following conditions:
//		1.	Re < 2100
//		2.	Residence time < 10 s
//		3.	Pressure differential < 2 torr
//
//	The last 2 conditions come from the EPA Quality Assurance Handbook for
//	Air Pollution Measurement Systems, Volume 2:
//	https://www3.epa.gov/ttn/amtic/qalist.html
//
//	Reynolds = (flow rate * diameter)/(kinematic viscosity * area)
//	Pressure differential = (8 * dynamic viscosity * length * flow rate)/(Pi * radius^4)
//
//	Source of kinematic and dynamic viscosities (1 atm):
//	https://www.me.psu.edu/cimbala/me433/Links/Table_A_9_CC_Properties_of_Air.pdf

////////////////////////////////////////////////////////////////////////////////

//	Diameter: inner diameter of tubing (m)
//	Length: length of tubing (m)
//	Input flow rate: sum of instrument flow rates (L min-1)
Function FlowRateGraph(v_diameter_m, v_length_m, v_maxFlowRate_lpm)
	Variable v_diameter_m, v_length_m, v_maxFlowRate_lpm

	Variable v_nu
	Variable v_mu
	Variable v_area_m2
	Variable v_tubeVolume_m3
	Variable v_flowRate_m3ps
	Variable v_numpnts = 201 // Number of flow rate points.
	Variable iloop

	v_nu = 1.562e-5 // kinematic viscosity of air at 25 C (m2 s-1)
	v_mu = 1.849e-5 // dynamic viscosity of air at 25 C (kg m-1 s-1)

	v_area_m2 = Pi * (v_diameter_m/2)^2 // m2
	v_tubeVolume_m3 = v_area_m2 * v_length_m // m3

	// Wave of flow rates to be put on the x-axis.
	Make/O/D/N=(v_numpnts) w_flowRate_lpm = NaN

	// Wave of Reynolds numbers per flow rate.
	Make/O/D/N=(v_numpnts) w_Reynolds = NaN

	// Wave of residence times per flow rate.
	Make/O/D/N=(v_numpnts) w_residenceTime_s = NaN

	// Wave of pressure differentials per flow rate.
	Make/O/D/N=(v_numpnts) w_pressureDiff_torr
	
	// Wave of flow rates recommended for use.
	Make/O/D/N=0 w_flowRate_recommended

	// Calculate with flow rate on the x-axis.
	For(iloop = 0; iloop < v_numpnts; iloop += 1)
		w_flowRate_lpm[iloop] = iloop * v_maxFlowRate_lpm/v_numpnts

		v_flowRate_m3ps = w_flowRate_lpm[iloop] * 1/1000 * 1/60

		w_Reynolds[iloop] = (v_flowRate_m3ps * v_diameter_m)/(v_nu * v_area_m2)

		w_residenceTime_s[iloop] = v_tubeVolume_m3/v_flowRate_m3ps
		
		w_pressureDiff_torr[iloop] = (8 * v_mu * v_length_m * v_flowRate_m3ps)/(Pi * (v_diameter_m/2)^4) * 0.0075
	EndFor

	// Prints recommended flow rate range.
	For(iloop = 0; iloop < v_numpnts; iloop += 1)
		If(w_residenceTime_s[iloop] < 10 && w_Reynolds[iloop] < 2100 && w_pressureDiff_torr[iloop] < 2)
			InsertPoints/M=0 numpnts(w_flowRate_recommended), 1, w_flowRate_recommended
			w_flowRate_recommended[numpnts(w_flowRate_recommended) - 1] = w_flowRate_lpm[iloop]
		EndIf
	EndFor
	
	If(numpnts(w_flowRate_recommended) > 1)
		Print "Recommended flow rate: ", wavemin(w_flowRate_recommended), " to ", wavemax(w_flowRate_recommended), "L/min"
	Else
		Print "No suitable flow rate range found. Consider changing tubing diameter or length."
	EndIf

	// Display figure.
	Display/K=1 w_Reynolds vs w_flowRate_lpm; DelayUpdate
	AppendToGraph/R w_residenceTime_s vs w_flowRate_lpm; DelayUpdate
	AppendToGraph/R=PressureDiff w_pressureDiff_torr vs w_flowRate_lpm; DelayUpdate
	Label left "Reynolds (Laminar: Re < 2100)"; DelayUpdate
	Label right "Residence time (sec)"; DelayUpdate
	Label bottom "Flow rate (L/min)"; DelayUpdate
	Label PressureDiff "Pressure Differential (torr)"; DelayUpdate
	ModifyGraph rgb(w_pressureDiff_torr)=(0,0,0), rgb(w_Reynolds)=(0,0,65535); DelayUpdate
	ModifyGraph lstyle(w_residenceTime_s)=3, lstyle(w_pressureDiff_torr)=5; DelayUpdate
	ModifyGraph mode=0, standoff=0, lsize=3; DelayUpdate
	ModifyGraph margin(right)=108; DelayUpdate
	ModifyGraph lblPos(right)=44; DelayUpdate
	ModifyGraph lblPos(PressureDiff)=40; DelayUpdate
	ModifyGraph freePos(PressureDiff)=50; DelayUpdate
	SetAxis left 0,(ceil(wavemax(w_Reynolds)/100) * 100); DelayUpdate
	SetAxis right 0,20; DelayUpdate
	SetAxis PressureDiff 0,(ceil(1.5*wavemax(w_pressureDiff_torr))); DelayUpdate
	Legend/C/N=text0/A=MC; DelayUpdate

End