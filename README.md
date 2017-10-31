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
| SBE39plus | .cnv | Convert to cnv format using SBE DataProcessingTools |
| SBE56	| .cnv |	%setting for export are: file type: .cnv, %date format: prefer NOT julian days, %miscelleanous: output informational header. |
| WQM	| .dat	| WQM Host processed DAT file |
| Wetlabs (FL)NTU | .raw | the corresponding DEV file must be in the same folder and have the same base name eg if you data file is test.DAT the the dev file is test.DEV |
| TR1060	| .txt	| Use Ruskin v1.7.19 or later, open your hex file. Right click on the dataset in the navigator window and export as Rtext using engineering format. Newer version of Ruskin use legacy Rtext option. |
| TDR2050	| .txt	| Use Ruskin v1.7.19 or later, open your hex file. Right click on the dataset in the navigator window and export as Rtext using engineering format. Newer version of Ruskin use legacy Rtext option. |
| RDI	| 000	| Standard PD0 format as downloaded from instrument. |
| Nortek AWAC & Continental  | .wpr, .wpb | raw WPR or Storm WPB |
| Nortek Aquadopp | .aqd | Nortek Aquadopp |
| Nortek Profiler | .prf | Nortek Profiler |
| Vemco Minilog-II-T	| .csv	| From Logger Vue software export VLD file as CSV. |
| IMOS Netcdf | .nc | IMOS netcdf file |
| Other Netcdf | .nc | Some other netcdf file. May not always work. (*local non-imosToolbox parser*) |
| RBR | .rsk | RBR files in newer rsk format (*local non-imosToolbox parser*) |
| VMDAS/WinRiverII RDI | .000, .PD0 | (*local non-imosToolbox parser*) |
| Nortek Vector | .vec | Nortek Vector (*AIMS imos-toolbox branch only*) |
| Hobo U22 | .txt | Hobo U22 temperature sensor (*AIMS imos-toolbox branch only*) |
| Citadel CTD | .csv | Citadel CTD csv export. (*AIMS imos-toolbox branch only*) |
| InsituMarineOptics | .log | IMO log format files, requires conversion from DL3 txt file. (*AIMS imos-toolbox branch only*) |

## Keyboard shortcuts

| Key | Action |
| --- | --- |
|   **Mouse actions in 2D mode** | |
|   *Normal mode* | |
|       single-click and holding LB | Activation Drag mode |
|       single-click and holding RB | Activation Rubber Band for region zooming |
|       single-click MB             | Activation 'Extend' Zoom mode |
|       scroll wheel MB             | Activation Zoom mode |
|       double-click LB, RB, MB     | Reset to Original View |
|   *Magnifier mode* | |
|       single-click LB             | Not Used |
|       single-click RB             | Not Used |
|       single-click MB             | Reset Magnifier to Original View |
|       scroll MB                   | Change Magnifier Zoom |
|       double-click LB             | Increase Magnifier Size |
|       double-click RB             | Decrease Magnifier Size |
|   *Hotkeys in 2D mode* | |
|       '+'                         | Zoom plus |
|       '-'                         | Zoom minus |
|       '0'                         | Set default axes (reset to original view) |
|       'uparrow'                   | Up or down (inrerse) drag |
|       'downarrow'                 | Down or up (inverse) drag |
|       'leftarrow'                 | Left or right (inverse) drag |
|       'rightarrow'                | Right or left (inverse) drag |
|       'c'                         | On/Off Pointer Symbol 'fullcrosshair' |
|       'g'                         | On/Off Axes Grid |
|       'x'                         | If pressed and holding, zoom and drag works only for X axis |
|       'y'                         | If pressed and holding, zoom and drag works only for Y axis |
|       'm'                         | If pressed and holding, Magnifier mode on |
|       'l'                         | On/Off Synchronize XY manage of 2-D axes |
|       'control+l'                 | On Synchronize X manage of 2-D axes |
|       'alt+l'                     | On Synchronize Y manage of 2-D axes |
|       's'                         | On/Off Smooth Plot (Experimental) |
| 'v' | print variable data nearest to mouse location (formerly Shift-leftmouseclick) |