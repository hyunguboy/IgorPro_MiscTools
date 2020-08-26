﻿#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function HKang_CoeffOfDetermination(w_dataX, w_dataY, w_modelX, w_modelY)
	Wave w_dataX, w_dataY, w_modelX, w_modelY

	Variable v_R2
	Variable iloop

	Duplicate/O w_dataX, w_TotalSSTemp	// wave used to find total sum of squares
	Duplicate/O w_dataX, w_ResidSSTemp	//	wave used to find residual sum of squares

	For(iloop = 0; iloop < numpnts(w_dataX); iloop += 1)
		w_TotalSSTemp[iloop] = (w_dataY[iloop] - mean(w_dataY))^2

		FindValue/V=(w_dataX[iloop]) w_modelX

		w_ResidSSTemp[iloop] = (w_dataY[iloop] - w_modelY[V_value])^2
	EndFor

	v_R2 = 1 - sum(w_ResidSSTemp)/sum(w_TotalSSTemp)

	Return v_R2

End