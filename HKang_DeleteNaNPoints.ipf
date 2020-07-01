#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.0

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.1 (Released 2020-07-01)
//	1.	Fixed bugs when the output wave should have no points.
//
//	Version 1.0 (Released 2020-06-30)
//	1.	Initial release tested with Igor Pro 6.37 and 8.04.

////////////////////////////////////////////////////////////////////////////////

//	'HKang_DeleteNaNPointsList' takes time series wave(s) and the corresponding
//	time wave and removes points where the time series values are NaN.
//
//	'HKang_DeleteNaNPointsSingle' takes a time series wave and the corresponding
//	time wave and removes points where the time series values are NaN.
//
//	For both of the above functions, all the waves being input (and the waves
//	in the list) need to be in the data folder where the function runs.

////////////////////////////////////////////////////////////////////////////////

//	str_concWaveList needs to be in the format of "wave0;...waveN;".
Function HKang_DeleteNaNPointsList(str_concWaveList, w_time)
	Wave w_time
	String str_concWaveList

	Variable v_numNaNs
	Variable iloop, jloop, kloop
	String str_removeNaNTemp

	If(itemsinlist(str_concWaveList, ";") < 1)
		Abort "Aborting: No items found in str_concWaveList."
	EndIf

	// Duplicate concentration waves to remove NaN values.
	For(iloop = 0; iloop < itemsinlist(str_concWaveList, ";"); iloop += 1)
		str_removeNaNTemp = stringfromlist(iloop, str_concWaveList, ";") + "_noNaN"
		
		Duplicate/O $stringfromlist(iloop, str_concWaveList, ";"), $str_removeNaNTemp
	EndFor

	// Make time wave for the no NaN concentration waves.
	str_removeNaNTemp = nameofwave(w_time) + "_noNaN"

	Duplicate/O w_time, $str_removeNaNTemp

	// Remove the NaN points.
	iloop = 0

	Do

		// Break condition.
		If(iloop == numpnts($nameofwave(w_time) + "_noNaN"))
			Break
		EndIf

		// Check if there is NaN at a given time point in the listed waves.
		For(jloop = 0; jloop < itemsinlist(str_concWaveList, ";"); jloop += 1)
			str_removeNaNTemp = stringfromlist(jloop, str_concWaveList, ";") + "_noNaN"

			Wave w_removeNaNTemp0 = $str_removeNaNTemp

			If(numtype(w_removeNaNTemp0[iloop]) == 2)

				// Delete NaN point in the concentration waves.
				For(kloop = 0; kloop < itemsinlist(str_concWaveList, ";"); kloop += 1)
					str_removeNaNTemp = stringfromlist(kloop, str_concWaveList, ";") + "_noNaN"

					Wave w_removeNaNTemp1 = $str_removeNaNTemp					

					DeletePoints/M=0 iloop, 1, w_removeNaNTemp1
				EndFor

				// Delete time point.
				DeletePoints/M=0 iloop, 1, $nameofwave(w_time) + "_noNaN"

				iloop -= 1
				
				Break
			EndIf
		EndFor

		iloop += 1
	While(1)

	// Table for quick look.
	Edit/K=1 $nameofwave(w_time) + "_noNaN"

	For(iloop = 0; iloop < itemsinlist(str_concWaveList); iloop += 1)
		str_removeNaNTemp = stringfromlist(iloop, str_concWaveList, ";") + "_noNaN"
		
		AppendToTable $str_removeNaNTemp
	EndFor

	v_numNaNs = numpnts(w_time) - numpnts($nameofwave(w_time) + "_noNaN")
	Print "Number of points removed: ", v_numNaNs

End

////////////////////////////////////////////////////////////////////////////////

Function HKang_DeleteNaNPointsSingle(w_conc, w_time)
	Wave w_conc, w_time

	Variable v_numNaNs
	Variable iloop, jloop, kloop
	String str_removeNaNTemp

	// Duplicate concentration wave to remove NaN values.
	str_removeNaNTemp = nameofwave(w_conc) + "_noNaN"

	Duplicate/O w_conc, $str_removeNaNTemp

	Wave w_removeNaNTemp0 = $str_removeNaNTemp

	// Make time wave for the no NaN concentration waves.
	str_removeNaNTemp = nameofwave(w_time) + "_noNaN"

	Duplicate/O w_time, $str_removeNaNTemp

	// Remove the NaN points.
	iloop = 0

	Do
		If(iloop == numpnts($nameofwave(w_time) + "_noNaN"))
			Break
		EndIf

		If(numtype(w_removeNaNTemp0[iloop]) == 2)

			// Delete NaN point in the concentration wave.
			DeletePoints/M=0 iloop, 1, w_removeNaNTemp0

			// Delete time point.
			DeletePoints/M=0 iloop, 1, $nameofwave(w_time) + "_noNaN"

			iloop -= 1
		EndIf

		iloop += 1
	While(1)

	// Table for quick look.
	Edit/K=1 $nameofwave(w_time) + "_noNaN", w_removeNaNTemp0

	Print "Number of points removed: ", numpnts(w_time) - numpnts($nameofwave(w_time) + "_noNaN")

End