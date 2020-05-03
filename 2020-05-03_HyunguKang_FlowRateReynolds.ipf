#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//	Flow rate: L min-1
//	Length: length of tubing (m)
//	Diameter: inner diameter of tubing (m)

//	Source of kinematic viscosity:
//	https://www.me.psu.edu/cimbala/me433/Links/Table_A_9_CC_Properties_of_Air.pdf

Function FlowRateGraph(v_diameter_m, v_length_m, v_maxFlowRate_lpm)
	Variable v_diameter_m, v_length_m, v_maxFlowRate_lpm

	Variable v_nu
	Variable v_area_m2
	Variable v_tubeVolume_m3
	Variable v_flowRate_m3ps
	Variable iloop

	v_nu = 1.562e-5 // kinematic viscosity of air at 25 C (m2 s-1)

	v_area_m2 = Pi * (v_diameter_m/2)^2 // m2

	v_tubeVolume_m3 = v_area_m2 * v_length_m // m3

	// Wave of flow rates to be put on the x-axis.
	Make/O/D/N=101 w_flowRate_lpm = NaN

	// Wave of Reynolds numbers per flow rate.
	Make/O/D/N=101 w_Reynolds = NaN

	// Wave of residence times per flow rate.
	Make/O/D/N=101 w_residenceTime_s = NaN

	For(iloop = 0; iloop < 101; iloop += 1)
		w_flowRate_lpm[iloop] = iloop * v_maxFlowRate_lpm/100

		v_flowRate_m3ps = w_flowRate_lpm[iloop] * 1/1000 * 1/60

		w_Reynolds[iloop] = (v_flowRate_m3ps * v_diameter_m)/(v_nu * v_area_m2)

		w_residenceTime_s[iloop] = v_tubeVolume_m3/v_flowRate_m3ps
	EndFor

	// Display figure.
	Display/K=1 w_Reynolds vs w_flowRate_lpm; DelayUpdate
	AppendToGraph/R w_residenceTime_s vs w_flowRate_lpm; DelayUpdate
	ModifyGraph standoff=0
	Label left "Reynolds (Laminar: Re < 2100)"
	Label right "Residence time (sec)"
	Label bottom "Flow rate (L/min)"
	ModifyGraph standoff=0
	ModifyGraph lsize=3,rgb(w_Reynolds)=(0,0,65535)
	Legend/C/N=text0/A=MC

End
