#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma version = 1.0

//	2020 Hyungu Kang, www.hazykinetics.com, hyunguboy@gmail.com
//
//	GNU GPLv3. Please feel free to modify the code as necessary for your needs.
//
//	Version 1.0 (Released 2020-06-02)
//	1.	Initial release tested with Igor Pro 6.37 and 8.04.

////////////////////////////////////////////////////////////////////////////////

//	Finds the linear correlation between AMS PMF factor time series and ion
//	mass time series. For both functions, the times series waves need to be
//	in the same data folder.
//
//	ListMultiR2: Takes a string list of ions.
//	MatrixMultiR2: Takes the entire matrix of ions against time.

////////////////////////////////////////////////////////////////////////////////

//	w_factor: PMF factor time series.
//	str_wavelist: List of ions in the form of "ion1;ion2;...;".
Function ListMultiR2(w_factor, str_waveList)
	Wave w_factor
	String str_waveList

	Variable iloop
	Variable ilist
	Variable v_itemsInList
	String str_waveFromList

	// Get number of ions in list.
	v_itemsInList = itemsinlist(str_waveList, ";")

	// Waves to be output.
	Make/O/D/N=(v_itemsInList) w_R2 = NaN
	Make/O/T/N=(v_itemsInList) w_species = ""

	For(iloop = 0; iloop < v_itemsInList; iloop += 1)
		str_waveFromList = stringfromlist(iloop, str_waveList, ";")

		Wave w_temp = root:$str_waveFromList
		
		CurveFit/Q line, w_temp/x=w_factor
		
		w_R2[iloop] = V_r2
		w_species[iloop] = str_waveFromList
	EndFor

	// Quick view.
	Edit/K=1 w_species, w_R2
	Display/K=1 w_R2

End

////////////////////////////////////////////////////////////////////////////////

//	w_factor: PMF factor time series.
//	w_matrix: Matrix of ions (columns) against time (rows).
//	w_speciesText: Text wave of the ion names. Needs to match the column length
//		of the matrix.
Function MatrixMultiR2(w_factor, w_matrix, w_speciesText)
	Wave w_factor, w_matrix
	Wave/T w_speciesText

	Variable iloop
	Variable ilist

	Make/O/D/N=(DimSize(w_matrix, 1)) w_R2
	Make/O/T/N=(DimSize(w_matrix, 1)) w_species

	For(iloop = 0; iloop < DimSize(w_matrix, 1); iloop += 1)
		CurveFit/Q line, w_matrix[][iloop]/x=w_factor

		w_R2[iloop] = V_r2
		w_species[iloop] = w_speciesText[iloop]
	EndFor

	// Quick view.
	Edit/K=1 w_species, w_R2
	Display/K=1 w_R2

End