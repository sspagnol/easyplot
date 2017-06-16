function sample_data = readXRrsk_local( filename, mode )
%readXRrsk Parses a rsk data file retrieved from newer Logger2 style
% insturments, currently RBRsolo, RBRvirtuoso, RBRduo, RBRconcerto, RBRmaestro
%
% Parses a rsk data file retrieved from newer Logger2 style insturments,
% currently RBRsolo, RBRvirtuoso, RBRduo, RBRconcerto, RBRmaestro.
% Utilizes RBR provided software (RSKtools for MATLAB)to read rsk (an
% sqlite file).
%
% The code downloadable from https://rbr-global.com/support/matlab-tools,
% and hosted on https://bitbucket.org/rbr/rsktools).
%
% Currently really only handles TEMP, PSAL, PRES, CNDC
%
% Inputs:
%   filename    - Cell array containing the name of the file to parse.
%   mode        - Toolbox data type mode.
%
% Outputs:
%   sample_data - Struct containing imported sample data.
%
% Author :  Guillaume Galibert <guillaume.galibert@utas.edu.au>
%           Simon Spagnol <s.spagnol@aims.gov.au>
%
%
%
% Copyright (c) 2017, Australian Ocean Data Network (AODN) and Integrated
% Marine Observing System (IMOS).
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
%     * Redistributions of source code must retain the above copyright notice,
%       this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in the
%       documentation and/or other materials provided with the distribution.
%     * Neither the name of the AODN/IMOS nor the names of its contributors
%       may be used to endorse or promote products derived from this software
%       without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.
%
narginchk(2,2);

if ~ischar(filename)
    error('filename must be a string');
end

% open the file, and read in the header and data
try
    RSK = RSKopen(filename);
    RSK = RSKreaddata(RSK);
catch e
    disp('readXRrsk: error reading rsk file.');
    rethrow(e);
end

% copy all of the information over to the sample data struct
sample_data = struct;

sample_data.toolbox_input_file                = filename;
sample_data.meta.instrument_make              = 'RBR';
sample_data.meta.instrument_model             = char(RSK.instruments.model);
try
    sample_data.meta.instrument_firmware          = RSK.instruments.firmwareVersion;
catch
    try
        sample_data.meta.instrument_firmware          = RSK.deployments.firmwareVersion;
    catch
        sample_data.meta.instrument_firmware      = 'UNKNOWN';
    end
end
try
    sample_data.meta.instrument_firmware_type     = RSK.instruments.firmwareType;
catch
    try
        sample_data.meta.instrument_firmware_type         = RSK.deployments.instrument_firmware_type;
    catch
        sample_data.meta.instrument_firmware_type     = 'UNKONWN';
    end
end
sample_data.meta.instrument_serial_no         = num2str(RSK.instruments.serialID);
sample_data.meta.instrument_sample_interval   = median(diff(RSK.data.tstamp*24*3600));
sample_data.meta.featureType                  = mode;

% save everything but data in RSK structure for future reference
for name = fieldnames(RSK)'
   name=char(name);
   if strcmpi(name,'data'); continue; end
   sample_data.meta.RSK.(name) = RSK.(name);
end

sample_data.dimensions = {};
sample_data.variables  = {};

[longNames, shortNames, data, comments] = convertRSK(RSK);

switch mode
    case 'profile'
        % dimensions creation
        iVarPRES = NaN;
        iVarDEPTH = NaN;
        isZ = false;
        nVars = length(longNames);
        for k = 1:nVars
            if strcmpi('Depth', longNames{k})
                iVarDEPTH = k;
                isZ = true;
                break;
            end
            if strcmpi('Pressure', longNames{k})
                iVarPRES = k;
                isZ = true;
            end
            if ~isnan(iVarDEPTH) && ~isnan(iVarPRES), break; end
        end
        
        if ~isZ
            error('There is no pressure or depth information in this file to use it in profile mode');
        end
        
        depthComment = '';
        if ~isnan(iVarDEPTH)
            iVarZ = iVarDEPTH;
            depthData = RSK.data.value(:,chanCol(iVarDEPTH));
        else
            iVarZ = iVarPRES;
            depthData = RSK.data.value(:,chanCol(iVarPRES)) - gsw_P0/10^4;
            presComment = ['abolute '...
                'pressure measurements to which a nominal '...
                'value for atmospheric pressure (10.1325 dbar) '...
                'has been substracted'];
            depthComment  = ['Depth computed from '...
                presComment ', assuming 1dbar ~= 1m.'];
        end
        
        % let's distinguish descending/ascending parts of the profile
        nData = length(RSK.data.value(:,chanCol(iVarZ)));
        zMax = max(data.(longNames{iVarZ}));
        posZMax = find(data.(longNames{iVarZ}) == zMax, 1, 'last'); % in case there are many times the max value
        iD = [true(posZMax, 1); false(nData-posZMax, 1)];
        
        nD = sum(iD);
        nA = sum(~iD);
        MAXZ = max(nD, nA);
        
        dNaN = nan(MAXZ-nD, 1);
        aNaN = nan(MAXZ-nA, 1);
        
        if nA == 0
            sample_data.dimensions{1}.name            = 'DEPTH';
            sample_data.dimensions{1}.typeCastFunc    = str2func(netcdf3ToMatlabType(imosParameters(sample_data.dimensions{1}.name, 'type')));
            sample_data.dimensions{1}.data            = sample_data.dimensions{1}.typeCastFunc(depthData);
            sample_data.dimensions{1}.comment         = depthComment;
            sample_data.dimensions{1}.axis            = 'Z';
            
            sample_data.variables{end+1}.name         = 'PROFILE';
            sample_data.variables{end}.typeCastFunc   = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
            sample_data.variables{end}.data           = sample_data.variables{end}.typeCastFunc(1);
            sample_data.variables{end}.dimensions     = [];
        else
            sample_data.dimensions{1}.name            = 'MAXZ';
            sample_data.dimensions{1}.typeCastFunc    = str2func(netcdf3ToMatlabType(imosParameters(sample_data.dimensions{1}.name, 'type')));
            sample_data.dimensions{1}.data            = sample_data.dimensions{1}.typeCastFunc(1:1:MAXZ);
            
            sample_data.dimensions{2}.name            = 'PROFILE';
            sample_data.dimensions{2}.typeCastFunc    = str2func(netcdf3ToMatlabType(imosParameters(sample_data.dimensions{2}.name, 'type')));
            sample_data.dimensions{2}.data            = sample_data.dimensions{2}.typeCastFunc([1, 2]);
            
            disp(['Warning : ' sample_data.toolbox_input_file ...
                ' is not IMOS CTD profile compliant. See ' ...
                'http://help.aodn.org.au/help/sites/help.aodn.org.au/' ...
                'files/ANMN%20CTD%20Processing%20Procedures.pdf']);
        end
        
        % Add TIME, DIRECTION and POSITION infos
        descendingTime = RSK.data.tstamp(iD);
        descendingTime = descendingTime(1);
        
        if nA == 0
            ascendingTime = [];
            dimensions = [];
        else
            ascendingTime = RSK.data.tstamp(~iD);
            ascendingTime = ascendingTime(1);
            dimensions = 2;
        end
        
        sample_data.variables{end+1}.dimensions   = dimensions;
        sample_data.variables{end}.name         = 'TIME';
        sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        sample_data.variables{end}.data         = sample_data.variables{end}.typeCastFunc([descendingTime, ascendingTime]);
        sample_data.variables{end}.comment      = 'First value over profile measurement.';
        
        sample_data.variables{end+1}.dimensions = dimensions;
        sample_data.variables{end}.name         = 'DIRECTION';
        sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        if nA == 0
            sample_data.variables{end}.data     = {'D'};
        else
            sample_data.variables{end}.data     = {'D', 'A'};
        end
        
        sample_data.variables{end+1}.dimensions = dimensions;
        sample_data.variables{end}.name         = 'LATITUDE';
        sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        if nA == 0
            sample_data.variables{end}.data     = sample_data.variables{end}.typeCastFunc(NaN);
        else
            sample_data.variables{end}.data     = sample_data.variables{end}.typeCastFunc([NaN, NaN]);
        end
        
        sample_data.variables{end+1}.dimensions = dimensions;
        sample_data.variables{end}.name         = 'LONGITUDE';
        sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        if nA == 0
            sample_data.variables{end}.data     = sample_data.variables{end}.typeCastFunc(NaN);
        else
            sample_data.variables{end}.data     = sample_data.variables{end}.typeCastFunc([NaN, NaN]);
        end
        
        sample_data.variables{end+1}.dimensions = dimensions;
        sample_data.variables{end}.name         = 'BOT_DEPTH';
        sample_data.variables{end}.comment      = 'Bottom depth measured by ship-based acoustic sounder at time of CTD cast.';
        sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        if nA == 0
            sample_data.variables{end}.data     = sample_data.variables{end}.typeCastFunc(NaN);
        else
            sample_data.variables{end}.data     = sample_data.variables{end}.typeCastFunc([NaN, NaN]);
        end
        
        % Manually add variable DEPTH if multiprofile and doesn't exit
        % yet
        if isnan(iVarDEPTH) && (nA ~= 0)
            sample_data.variables{end+1}.dimensions = [1 2];
            
            sample_data.variables{end}.name         = 'DEPTH';
            sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
            
            % we need to padd data with NaNs so that we fill MAXZ
            % dimension
            sample_data.variables{end}.data         = sample_data.variables{end}.typeCastFunc([[depthData(iD); dNaN], [depthData(~iD); aNaN]]);
            
            sample_data.variables{end}.comment      = depthComment;
            sample_data.variables{end}.axis         = 'Z';
        end
        
        % scan through the list of parameters that were read
        % from the file, and create a variable for each
        for name = fieldnames(data)'
            name = char(name);
            % we skip DEPTH
            if strcmpi('DEPTH', name) && (nA == 0), continue; end
            
            sample_data.variables{end+1}.dimensions = [1 dimensions];
            
            sample_data.variables{end}.name         = name;
            sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
            if nA == 0
                sample_data.variables{end  }.data   = sample_data.variables{end}.typeCastFunc(data.(name)(iD));
            else
                % we need to padd data with NaNs so that we fill MAXZ
                % dimension
                sample_data.variables{end  }.data   = sample_data.variables{end}.typeCastFunc([[data.(name)(iD); dNaN], [data.(name)(~iD); aNaN]]);
            end
            sample_data.variables{end}.comment    = comments.(name);
            
            if ~any(strcmpi(longNames{k}, {'TIME', 'DEPTH'}))
                sample_data.variables{end  }.coordinates = 'TIME LATITUDE LONGITUDE DEPTH';
            end
        end
        
        sample_data = processDOXS(sample_data);
        
    case 'timeSeries'
        sample_data.dimensions{1}.name            = 'TIME';
        sample_data.dimensions{1}.typeCastFunc    = str2func(netcdf3ToMatlabType(imosParameters(sample_data.dimensions{1}.name, 'type')));
        sample_data.dimensions{1}.data            = sample_data.dimensions{1}.typeCastFunc(RSK.data.tstamp);
        
        sample_data.variables{end+1}.name           = 'TIMESERIES';
        sample_data.variables{end}.typeCastFunc     = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        sample_data.variables{end}.data             = sample_data.variables{end}.typeCastFunc(1);
        sample_data.variables{end}.dimensions       = [];
        sample_data.variables{end+1}.name           = 'LATITUDE';
        sample_data.variables{end}.typeCastFunc     = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        sample_data.variables{end}.data             = sample_data.variables{end}.typeCastFunc(NaN);
        sample_data.variables{end}.dimensions       = [];
        sample_data.variables{end+1}.name           = 'LONGITUDE';
        sample_data.variables{end}.typeCastFunc     = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        sample_data.variables{end}.data             = sample_data.variables{end}.typeCastFunc(NaN);
        sample_data.variables{end}.dimensions       = [];
        sample_data.variables{end+1}.name           = 'NOMINAL_DEPTH';
        sample_data.variables{end}.typeCastFunc     = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        sample_data.variables{end}.data             = sample_data.variables{end}.typeCastFunc(NaN);
        sample_data.variables{end}.dimensions       = [];
        
        coordinates = 'TIME LATITUDE LONGITUDE NOMINAL_DEPTH';
        
        for name = fieldnames(data)'
            name = char(name);
            % dimensions definition must stay in this order : T, Z, Y, X, others;
            % to be CF compliant
            sample_data.variables{end+1}.dimensions = 1;
            sample_data.variables{end}.name         = name;
            sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
            sample_data.variables{end}.data         = sample_data.variables{end}.typeCastFunc(data.(name));
            sample_data.variables{end}.coordinates  = coordinates;
            sample_data.variables{end}.comment      = comments.(name);
        end
        
        sample_data = processDOXS(sample_data);
end
end

function [longNames, shortNames, data, comments] = convertRSK(RSK)
% convert RSK into simple structure with metadata and data unit conversions
% if necessary
%
% longName = cell array of RBR long form name of all variables
% shortName = cell array of RBR short form name of all variables
% data = data struct with IMOSified fieldnames
% comment = comment struct with IMOSified fieldnames

% RSK long/short name form of all variables
longNames = {RSK.channels.longName};
shortNames = {RSK.channels.shortName};
% index into RSK.data.value per variable
chanCol = [];
for chan = longNames
    chanCol = [chanCol getchannelindex(RSK, chan{1})];
end

for k = 1:length(longNames)
    name = '';
    comment = '';
    switch longNames{k}
        
        %Conductivity (mS/cm) = 10-1*(S/m)
        case 'Conductivity'
            name = 'CNDC';
            data.(name) = RSK.data.values(:,chanCol(k))/10;
            
            %Temperature (Celsius degree)
        case 'Temperature', name = 'TEMP';
            data.(name) = RSK.data.values(:,chanCol(k));
            
            %Pressure (dBar)
        case 'Pressure', name = 'PRES';
            data.(name) = RSK.data.values(:,chanCol(k));
            
            %Fluorometry-chlorophyl (ug/l) = (mg.m-3)
        case 'FlC'
            name = 'CPHL';
            comment = ['Artificial chlorophyll data computed from ' ...
                'fluorometry sensor raw counts measurements. Originally ' ...
                'expressed in ug/l, 1l = 0.001m3 was assumed.'];
            data.(name) = RSK.data.values(:,chanCol(k));
            
            %Turbidity (NTU)
        case 'Turbidity', name = 'TURB';
            data.(name) = RSK.data.values(:,chanCol(k));
            
            %Rinko temperature (Celsius degree)
        case 'R_Temp'
            name = '';
            comment = 'Corrected temperature.';
            data.(name) = RSK.data.values(:,chanCol(k));
            
            %Rinko dissolved O2 (%)
        case 'R_D_O2', name = 'DOXS';
            data.(name) = RSK.data.values(:,chanCol(k));
            
            %Depth (m)
        case 'Depth', name = 'DEPTH';
            data.(name) = RSK.data.values(:,chanCol(k));
            
            %Salinity (PSU)
        case 'Salinity', name = 'PSAL';
            data.(name) = RSK.data.values(:,chanCol(k));
            
            %Specific conductivity (uS/cm) = 10-4 * (S/m)
        case 'SpecCond'
            name = 'SPEC_CNDC';
            data.(name) = RSK.data.values(:,chanCol(k))/10000;
            
            %Density anomaly (n/a)
        case 'DensAnom', name = '';
            data.(name) = RSK.data.values(:,chanCol(k));
            
            %Speed of sound (m/s)
        case 'SoSUN', name = 'SSPD';
            data.(name) = RSK.data.values(:,chanCol(k));
            
            %Rinko dissolved O2 concentration (mg/l) => (umol/l)
        case 'rdO2C'
            name = 'DOX1';
            comment = ['Originally expressed in mg/l, ' ...
                'O2 density = 1.429kg/m3 and 1ml/l = 44.660umol/l were assumed.'];
            data.(name) = RSK.data.values(:,chanCol(k)) * 44.660/1.429; % O2 density = 1.429 kg/m3
            
            % Oxyguard dissolved O2 (%)
        case 'D_O2', name = 'DOXS';
            data.(name) = RSK.data.values(:,chanCol(k));
            
            % Oxyguard dissolved O2 concentration (ml/l) => (umol/l)
        case 'dO2C'
            name = 'DOX1';
            comment = ['Originally expressed in ml/l, ' ...
                '1ml/l = 44.660umol/l was assumed.'];
            data.(name) = RSK.data.values(:,chanCol(k))* 44.660;
        otherwise
            % genvarname will be deprecated sometime
            try
                name = genvarname(longNames{k});
            catch
                name = matlab.lang.makeValidName(longNames{k});
            end
            comment = 'UNKNOWN';
            data.(name) = RSK.data.values(:,chanCol(k));
    end
    
    if ~isempty(name)
        comments.(name) = comment;
    end
end
end

function sample_data = processDOXS(sample_data)
% Let's add DOX1/DOX2 if PSAL/CNDC, TEMP and DOXS are present and DOX1 not
% already present

doxs = getVar(sample_data.variables, 'DOXS');
dox1 = getVar(sample_data.variables, 'DOX1');
if doxs ~= 0 && dox1 == 0
    doxs = sample_data.variables{doxs};
    name = 'DOX1';
    
    % to perform this conversion, we need temperature,
    % and salinity/conductivity+pressure data to be present
    temp = getVar(sample_data.variables, 'TEMP');
    psal = getVar(sample_data.variables, 'PSAL');
    cndc = getVar(sample_data.variables, 'CNDC');
    pres = getVar(sample_data.variables, 'PRES');
    
    % if any of this data isn't present,
    % we can't perform the conversion
    if temp ~= 0 && (psal ~= 0 || (cndc ~= 0 && pres ~= 0))
        temp = sample_data.variables{temp};
        if psal ~= 0
            psal = sample_data.variables{psal};
        else
            cndc = sample_data.variables{cndc};
            pres = sample_data.variables{pres};
            % conductivity is in S/m and gsw_C3515 in mS/cm
            crat = 10*cndc.data ./ gsw_C3515;
            
            % we need to use relative pressure using gsw_P0 = 101325 Pa
            psal.data = gsw_SP_from_R(crat, temp.data, pres.data - gsw_P0/10^4);
        end
        
        % O2 solubility (Garcia and Gordon, 1992-1993)
        %
        solubility = O2sol(psal.data, temp.data, 'ml/l');
        
        % O2 saturation to O2 concentration measured
        % O2 saturation (per cent) = 100* [O2/O2sol]
        %
        % that is to say : O2 = O2sol * O2sat / 100
        data = solubility .* doxs.data / 100;
        
        % conversion from ml/l to umol/l
        data = data * 44.660;
        comment = ['Originally expressed in % of saturation, using Garcia '...
            'and Gordon equations (1992-1993) and ml/l coefficients, assuming 1ml/l = 44.660umol/l.'];
        
        sample_data.variables{end+1}.dimensions = 1;
        sample_data.variables{end}.comment      = comment;
        sample_data.variables{end}.name         = name;
        sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        sample_data.variables{end}.data         = sample_data.variables{end}.typeCastFunc(data);
        sample_data.variables{end}.coordinates  = coordinates;
        
        % Let's add DOX2
        name = 'DOX2';
        
        % O2 solubility (Garcia and Gordon, 1992-1993)
        %
        solubility = O2sol(psal.data, temp.data, 'umol/kg');
        
        % O2 saturation to O2 concentration measured
        % O2 saturation (per cent) = 100* [O2/O2sol]
        %
        % that is to say : O2 = O2sol * O2sat / 100
        data = solubility .* doxs.data / 100;
        comment = ['Originally expressed in % of saturation, using Garcia '...
            'and Gordon equations (1992-1993) and umol/kg coefficients.'];
        
        sample_data.variables{end+1}.dimensions = 1;
        sample_data.variables{end}.comment      = comment;
        sample_data.variables{end}.name         = name;
        sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        sample_data.variables{end}.data         = sample_data.variables{end}.typeCastFunc(data);
        sample_data.variables{end}.coordinates  = coordinates;
    end
end

% Let's add a new parameter if DOX1, PSAL/CNDC, TEMP and PRES are
% present and DOX2 not already present
dox1 = getVar(sample_data.variables, 'DOX1');
dox2 = getVar(sample_data.variables, 'DOX2');
if dox1 ~= 0 && dox2 == 0
    dox1 = sample_data.variables{dox1};
    name = 'DOX2';
    
    % umol/l -> umol/kg
    %
    % to perform this conversion, we need to calculate the
    % density of sea water; for this, we need temperature,
    % salinity, and pressure data to be present
    temp = getVar(sample_data.variables, 'TEMP');
    pres = getVar(sample_data.variables, 'PRES');
    psal = getVar(sample_data.variables, 'PSAL');
    cndc = getVar(sample_data.variables, 'CNDC');
    
    % if any of this data isn't present,
    % we can't perform the conversion to umol/kg
    if temp ~= 0 && pres ~= 0 && (psal ~= 0 || cndc ~= 0)
        temp = sample_data.variables{temp};
        pres = sample_data.variables{pres};
        if psal ~= 0
            psal = sample_data.variables{psal};
        else
            cndc = sample_data.variables{cndc};
            % conductivity is in S/m and gsw_C3515 in mS/cm
            crat = 10*cndc.data ./ gsw_C3515;
            
            % we need to use relative pressure using gsw_P0 = 101325 Pa
            psal.data = gsw_SP_from_R(crat, temp.data, pres.data - gsw_P0/10^4);
        end
        
        % calculate density from salinity, temperature and pressure
        dens = sw_dens(psal.data, temp.data, pres.data - gsw_P0/10^4); % cannot use the GSW SeaWater library TEOS-10 as we don't know yet the position
        
        % umol/l -> umol/kg (dens in kg/m3 and 1 m3 = 1000 l)
        data = dox1.data .* 1000.0 ./ dens;
        comment = ['Originally expressed in mg/l, assuming O2 density = 1.429kg/m3, 1ml/l = 44.660umol/l '...
            'and using density computed from Temperature, Salinity and Pressure '...
            'with the CSIRO SeaWater library (EOS-80) v1.1.'];
        
        sample_data.variables{end+1}.dimensions = 1;
        sample_data.variables{end}.comment      = comment;
        sample_data.variables{end}.name         = name;
        sample_data.variables{end}.typeCastFunc = str2func(netcdf3ToMatlabType(imosParameters(sample_data.variables{end}.name, 'type')));
        sample_data.variables{end}.data         = sample_data.variables{end}.typeCastFunc(data);
        sample_data.variables{end}.coordinates  = coordinates;
    end
end
end