function setup_easyplot(strType)

% path to easyplot dir
[EPpath, name, ext] = fileparts(mfilename('fullpath'));
%easyplotDir='D:\Projects\aims-gitlab\easyplot';
if nargin == 0
    strType='pc';
end

driveLetter='';
if ispc
    driveLetter=EPpath(1:2);
end

% baseDIR : typically top folder containing easyplot and imos-toolbox folders
% ITBdir : folder name of imos toolbox, assumes you have set imosToolbox so that imosToolbox.m already in your path
% EPdir : foldername of easyplot

switch strType
    case 'pc'
        %baseDIR=[driveLetter '\AIMS'];
        %AODNbaseDir=[driveLetter '\AIMS'];
        ITBdir = 'imos-toolbox-2.5-aims';
        %EPdir = 'easyplot'; % easyplot folder name
        thisFilepath = mfilename('fullpath');
        [baseDIR, EPdir] = fileparts(EPpath);

    case 'pc-dev'
        baseDIR=[driveLetter '\Projects\aims-gitlab'];
        AODNbaseDir=[driveLetter '\Projects\aodn'];
        ITBdir = 'imos-toolbox';
        EPdir = 'easyplot';
        
    case 'hpc'
        baseDIR='/export/ocean/AIMS';
        AODNbaseDir='/export/ocean/AIMS';
        ITBdir = 'imos-toolbox-2.5-aims';
        EPdir = 'easyplot';

    case 'hpc-dev'
        baseDIR='/export/ocean/sspagnol/src/aims-gitlab';
        AODNbaseDir='/export/ocean/sspagnol/src/github/aodn';
        ITBdir = 'imos-toolbox';
        EPdir = 'easyplot';
		
    otherwise
        [baseDIR, EPdir] = fileparts(EPpath);
        ITBdir = 'imos-toolbox';
        EPdir = 'easyplot';
end

% path to imosToolbox
ITBpath=fullfile(baseDIR, ITBdir);

% path to AIMS Easyplot
EPpath=fullfile(baseDIR, EPdir);

%%
reAddPaths(EPpath,'AIMS easyplot',true,'(snapshot)');

%% add IMOS Toolbox paths
reAddPaths(ITBpath,'IMOS toolbox',true);

end

%%
function reAddPaths(topDir,messageStr,atBeginning,excludePattern)

disp(['Adding paths for ' messageStr ', please wait...']);
try
if ~exist('excludePattern')
    excludePattern = '';
end    
    gp=genpath_clean(topDir, excludePattern);
    disp('  Removing any existing paths.')
    rempath(gp);
    disp('  Adding new paths');
    if atBeginning
        addpath(gp,'-begin');
    else
        addpath(gp);
    end
catch
    error(['Path ' topDir ' does not exist.']);
end

end

%%
function rempath(gp)
% from a genpath path string, remove on paths that are currently in the
% matlab path

ss=strsplit(gp,';');
pp=strsplit(path,';');
ii=ismember(ss,pp);
ss=ss(ii); %list with only directories that are currently on matlab path
if ~isempty(ss)
    thePath=sprintf(['%s' pathsep],ss{:}); %make string seperated by pathsep
    if thePath(end)==pathsep % remove last not needed pathsep
        thePath(end)=[];
    end
    rmpath(thePath);
end

end

%%
function thePath = genpath_clean( topDir, excludePattern )
%genpath_clean generate a path without .svn, .git etc.
%   generate a path without .svn, .git etc. Based on idea from OpenEarthTools

b=genpath(topDir);
s = strread(b, '%s','delimiter', pathsep);  % read path as cell
rpattern='(\.svn|\.git|\.hg\private)';
ii=cellfun(@isempty,regexp(s,rpattern,'match','once'));
s=s(ii); %cell array without .git etc
if ~isempty(excludePattern)
ii=cellfun(@isempty,regexp(s,excludePattern,'match','once'));
s=s(ii);
end
thePath=sprintf(['%s' pathsep],s{:}); %make string seperated by pathsep
if thePath(end)==pathsep % remove last not needed pathsep
    thePath(end)=[];
end

end