# IgorPro_MiscTools
Miscellaneous tools used in the lab or to write other functions.

## HKang_CoeffOfDetermination.ipf

Calculates the R<sup>2</sup> (coefficient of determination) value between 2 input waves. Ideally, this function can be used between a model output and measurement values.

## HKang_ConvertToNaNperiod.ipf

Takes time and concentration waves and designated times and converts the concentrations within those designated times to NaN.

## HKang_DeleteNaNPoints.ipf

Deletes NaN points in a wave.

## HKang_GetAvgWithTime.ipf

Calculates the average of points within an input time period. This function takes a wave of measurements, its corresponding time wave, and the beginning and end time points. It then outputs the average of the points in the period.

## HKang_GetMultipleR2.ipf

Finds the R2 from linear regressions of multiple waves (or matrix) and saves those R2 values into an output wave.

## HKang_LinearRegressionMethods.ipf

Multiple ways to calculate a linear regression.

## HKang_VaporPressClausClap.ipf

Calculates the vapor pressure using the Clausius-Clapeyron equation. Requires enthalpy of vaporization and a reference vapor pressure at some temperature.
