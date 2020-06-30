#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version=1.0

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.0 (Released 2020-06-30)
//	1.	Initial release tested with Igor Pro 6.37 and 8.04.

////////////////////////////////////////////////////////////////////////////////

//	'HKang_DeleteNaNPointsList' takes time series wave(s) and the corresponding
//	time wave and flags NaN points and removes those points.

////////////////////////////////////////////////////////////////////////////////

//	str_concWaveList needs to be in the format of "wave0;...waveN;".
Function HKang_DeleteNaNPointsList(str_concWaveList, w_time)
	Wave w_time
	String str_concWaveList

	Variable iloop, jloop
	String str_removeNaNTemp

	// 1: not NaN, 0: NaN.
	Make/O/I/N=(numpnts(w_time)) w_noNaNFlags = NaN
	
	If(itemsinlist(str_concWaveList, ";") < 1)
		Abort "Aborting: No items found in str_concWaveList."
	EndIf

	// Make no NaN concentration waves to be filled with values.
	For(iloop = 0; iloop < itemsinlist(str_concWaveList, ";"); iloop += 1)
		str_removeNaNTemp = stringfromlist(iloop, str_concWaveList, ";") + "_noNaN"
		
		Duplicate/O $stringfromlist(iloop, str_concWaveList, ";"), $str_removeNaNTemp
	EndFor

	// Make time wave for the no NaN concentration waves.
	str_removeNaNTemp = nameofwave(w_time) + "_noNaN"
	
	Make/O/D/N=0 $str_removeNaNTemp
	
	SetScale d, 0, 1, "dat", $str_removeNaNTemp

	// Fill the no NaN waves.
	iloop = 0
	
	Do
		For(jloop = 0; jloop < numpnts(w_time); jloop += 1)
			str_removeNaNTemp = stringfromlist(iloop, str_concWaveList, ";") + "_noNaN"

			Wave w_removeNaNTemp = $str_removeNaNTemp

			If(numtype(w_removeNaNTemp[iloop]) == 2)




			EndIf

		EndFor
		
		iloop += 1
	While(iloop < numpnts(w_removeNaNTemp))







End




