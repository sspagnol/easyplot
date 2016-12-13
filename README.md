The aim of easyplot is to deliver a simple to use program to plot and easily 
compare instrument data for diagnostic purposes. It is utilizes instrument 
parsers from imos-toolbox (https://github.com/aodn/imos-toolbox)

## Setting up

Assume the user has Matlab installed, and some form of imos-toolbox installed.

Required to specified paths to imos-toolbox and easyplot e.g.

```matlab
ITBdir = 'c:/processing/imos-toolbox';
EPdir =  'c:/processing/easyplot';
```


## Data files

Most raw instrument data files will require some sort of conversion in order for the IMOS routines to read them (the one exception is the RDI 000 file). Table 1 is the description on how output variable should be setup.  Using the IMOS routines means output order of variables in the file is not crucial, but some variables must be included in the output.


| Instrument |	Data file type expected	| Example output variables, bold variables must be included in output |
| --- | --- | --- |
| SBE16plus, CTDSBE19plus, CTDSBE25plus	| .cnv | Variables like 'Conductivity' 'Pressure' 'Temp' in whatever order. The variable 'time elapsed in second' must be included. |
| SBE37	| .asc |	As downloaded from instrument. |
| SBE37	| .cnv |	Variables like 'Pressure', 'Temp', 'Conductivity' in any order. The variable 'time elapsed in second' must be included. NOTE: if your SBE37 does not have a pressure sensor do not include a pressure variable in your data setup. |
| SBE39	| .asc |	As downloaded from instrument. |
| SBE56	| .cnv |	%setting for export are: file type: .cnv, %date format: prefer NOT julian days, %miscelleanous: output informational header. |
| WQM	| .dat	| WQM processed DAT file, the corresponding DEV file must be in the same folder and have the same base name eg if you data file is test.DAT the the dev file is test.DEV |
| TR1060	| .txt	| Use Ruskin v1.7.19 or later, open your hex file. Right click on the dataset in the navigator window and export as Rtext using engineering format. Newer version of Ruskin use legacy Rtext option. |
| TDR2050	| .txt	| Use Ruskin v1.7.19 or later, open your hex file. Right click on the dataset in the navigator window and export as Rtext using engineering format. Newer version of Ruskin use legacy Rtext option. |
| RDI	| 000	| Standard PD0 format as downloaded from instrument. |
| Wetlabs FLNTU	| raw	| The corresponding DEV file must be in the same folder and have the same base name. |
| Vemco Minilog-II-T	| csv	| From Logger Vue software export VLD file as CSV. |


Keyboard shortcuts

| Key | Action |
| --- | --- |
| z, Z | zoom in, zoom out, in both dimensions |
| x, X | zoom in, zoom out, x dimension only (for all plots) |
| y, Y | zoom in, zoom out, y dimension only (only current selected plot) |
| arrow keys | pan the data (only current selected plot), shift arrow increase panning factor |
| a | axis auto |
| Shift-leftmouseclick | display table of variables nearest timestamp selected. |