function sam = EP_addVar(sam, name, data, dimensions, comment, coordinates)
%EP_ADDVAR Adds a new variable to the given data set.
%
% Adds a new variable with the given name, data, dimensions and commment to
% the given data set.
%
% Inputs:
%   sam        - data set to which the new variable is added
%   name       - new variable name
%   data       - variable data
%   dimensions - variable dimensions
%   comment    - variable comment
%   coordinates- variable coordinates
%
% Outputs:
%   sam        - data set  with the new variable added.
%
% Author:       Paul McCarthy <paul.mccarthy@csiro.au>
% Contributor:  Guillaume Galibert <guillaume.galibert@utas.edu.au>
%

%
% Copyright (c) 2016, Australian Ocean Data Network (AODN) and Integrated
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
narginchk(6, 6);

if ~isstruct(sam),          error('sam must be a struct');        end
if ~ischar(name),           error('name must be a string');       end
if ~isnumeric(data),        error('data must be a matrix');       end
if ~isvector(dimensions),   error('dimensions must be a vector'); end
if ~ischar(comment),        error('comment must be a string');    end
if ~ischar(coordinates),    error('coordinates must be a string');end

qcSet   = str2double(readProperty('toolbox.qc_set'));
rawFlag = imosQCFlag('raw', qcSet, 'flag');

idxVar = getVar(sam.variables, name);
if idxVar == 0
    idxVar = length(sam.variables) + 1;
end

% add new variable to data set
sam.variables{idxVar}.name           = name;
sam.variables{idxVar}.typeCastFunc   = str2func(netcdf3ToMatlabType(imosParameters(sam.variables{end}.name, 'type')));
sam.variables{idxVar}.dimensions     = dimensions;
sam.variables{idxVar}.EP_OFFSET     = 0.0;
sam.variables{idxVar}.EP_SCALE     = 1.0;
if numel(dimensions) < 3
	sam.variables{idxVar}.EP_iSlice = 1;
else
	sam.variables{idxVar}.EP_iSlice = -1;
end
sam.variables{idxVar}.data           = sam.variables{end  }.typeCastFunc(data);
clear data;
if ~isempty(coordinates)
    sam.variables{idxVar}.coordinates = coordinates;
end

% create an empty flags matrix for the new variable
sam.variables{idxVar}.flags(1:numel(sam.variables{idxVar}.data)) = rawFlag;
sam.variables{idxVar}.flags = reshape(...
    sam.variables{idxVar}.flags, size(sam.variables{idxVar}.data));

% ensure that the new variable is populated  with all
% required NetCDF  attributes - all existing fields are
% left unmodified by the makeNetCDFCompliant function
%sam = makeNetCDFCompliant(sam);

if isfield(sam.variables{idxVar}, 'comment')
    sam.variables{idxVar}.comment       = comment;
end
