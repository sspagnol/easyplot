%% RSKtools for Matlab access to RBR data
% RSKtools v2.1.0;
% RBR Ltd. Ottawa ON, Canada;
% support@rbr-global.com;
% 2017-08-31

%% Introduction 
% |RSKtools| provides some convenience functions for common data
% extraction (e.g., extracting profiles from a continuous dataset) and
% visualisation (e.g., plotting individual profiles). As of v2.0.0,
% RSKtools includes a suite of functions to perform routine processing
% steps to enhance the data quality (see VignettePostProcessing for
% more information). From this version on, we are expanding our data
% post-processing suite. See the Future Plans for some ideas, and
% please feel free to make suggestions.

%% Installing
% The latest stable version of |RSKtools| can be found at <http://www.rbr-global.com/support/matlab-tools>.
% 
% * Unzip the archive (to |~/matlab/RSKtools|, for instance) 
% * Add the folder to your path from the command line (|addpath ~/matlab/RSKtools|) or launch the path editor gui (|pathtool|). 
% * type |help RSKtools| to get an overview and take a look at the examples.

  
%% Examples of use
% <html><h3>Loading files</h3></html>
% 
% A connection to the database must be made to work with an RSK file using
% |RSKtools|. This connection is made using the |RSKopen()| function. Note
% that |RSKopen| does not actually read the data, but reads a /thumbnail/ of
% the data, which is up to 4000 samples long. The structure returned after
% opening an RSK looks something like:

file = 'sample.rsk';
rsk = RSKopen(file)

%%
% To read the full dataset, use the |RSKreaddata| function.
% RSKreaddata will read the full dataset by default.  Because RSK
% files can store a large amount of data, it may be preferable to read
% a subset of the data, specified using a start and end time (in
% Matlab |datenum| format, which is defined as the number of days
% since January 0, 0000).

t1 = datenum(2014, 05, 03);
t2 = datenum(2014, 05, 04);
rsk = RSKreaddata(rsk, 't1', t1, 't2', t2);

%%
% Note that the logger data can be found in the structure at:

rsk.data        

%% 
% In this example, because the instrument is a "CTD"-type instrument,
% Practical Salinity can be derived from conductivity, temperature,
% and pressure.  |RSKderivesalinity| is a wrapper for the TEOS-10 GSW
% function |gsw_SP_from_C|, and it adds a new channel called
% |Salinity| as a column in |rsk.data.values|.  The TEOS-10 GSW Matlab
% toolbox is freely available from <http://teos-10.org/software.htm>.
% It is good practice to derive sea pressure first in case you want to
% specify a custom value of atmospheric pressure.

rsk = RSKderiveseapressure(rsk);
rsk = RSKderivesalinity(rsk);
{rsk.channels.longName}'

%% Working with profiles
% Profiling loggers with recent versions of firmware contain the
% ability to detect and log profile "events" automatically; these are
% denoted as "downcasts" and "upcasts". The function |RSKreadprofiles|
% extracts individual profiles from the raw data, based on the previously
% identified profiling events. Then, a plot of the profiles can be
% made very easily using the |RSKplotprofiles| function. 
%
% If profiles have not been detected by the logger or Ruskin, the function
% |RSKfindprofiles| can be used. The pressureThreshold argument, which
% determines the pressure reversal required to trigger a new profile, and
% the conductivityThreshold argument, which determines if the logger is
% out of the water, can be adjusted to improve profile detection when 
% the profiles are very shallow, or when the water is very fresh.
%
% Note: Salinity and sea pressure have to be derived again because
% |RSKreadprofiles| replaces the data field with the newly queried
% values.

% load the second to tenth profiles in both directions (upcast and downcast)
rsk = RSKreadprofiles(rsk, 'profile', 2:10, 'direction', 'both');
rsk = RSKderiveseapressure(rsk);
rsk = RSKderivesalinity(rsk);

% plot the upcasts of conductivity, temperature, and salinity
handles = RSKplotprofiles(rsk, 'channel', {'conductivity', 'temperature','salinity'}, 'direction', 'up');


%% Customising plots
% All plotting functions return a handle enabling access to the line
% objects. The output is a matrix containing a column for each channel
% subplot and a row for each profile.
handles

% To increase the line width of the first profile in all subplots
set(handles(1,:),{'linewidth'},{5});


%% Accessing individual channels and profiles
% The channel data is stored in |rsk.data|.  If the data was parsed
% into profiles, |data| is a 1xN structure array, where each element
% is an upcast or downcast from a single profile containing an array
% of time stamps and a matrix of channel data.  |RSKtools| has
% functions to make accessing the data easy.  For example, to access
% the time stamps, sea pressure, temperature, and dissolved O2, from
% the upcast of the 1st profile, run:

profind = getdataindex(rsk,'direction','up','profile',1);
tempcol = getchannelindex(rsk,'temperature');
o2col   = getchannelindex(rsk,'dissolved o2');
prescol = getchannelindex(rsk,'sea pressure');

time        = rsk.data(profind).tstamp;
seapressure = rsk.data(profind).values(:,prescol);
temperature = rsk.data(profind).values(:,tempcol);
o2          = rsk.data(profind).values(:,o2col);


%% Other Resources
% We recommend reading:
%
% * The <https://docs.rbr-global.com/rsktools RSKtools on-line user
% manual> for detailed RSKtools function documentation.
%
% * The <http://rbr-global.com/wp-content/uploads/2017/07/VignettePostProcessing.pdf
% RSKtools post-processing vignette> for an introduction on how to
% process RBR profiles with RSKtools.  The post-processing suite
% contains, among other things, functions to low-pass filter, align,
% de-spike data.



%% Future plans
% * Function to write metadata, log and data to a file.
% * Wave processing functions.
% * Function to plot temperature-salinity diagrams.

%% About this document
% This document was created using
% <http://www.mathworks.com/help/matlab/matlab_prog/marking-up-matlab-comments-for-publishing.html
% Matlab(TM) Markup Publishing>. To publish it as an HTML page, run the
% command:
%%
% 
%   publish('VignetteStandard.m');

%%
% See |help publish| for more document export options.