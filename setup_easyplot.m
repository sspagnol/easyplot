function setup_easyplot(strType)

% path to easyplot dir
[EPdir, name, ext] = fileparts(mfilename('fullpath'));
%easyplotDir='D:\Projects\aims-gitlab\easyplot';
if nargin == 0
    strType='pc';
end

switch strType
    case 'pc'
        baseDIR='D:\AIMS';
        AODNbaseDir='D:\AIMS';
        AMdir=fullfile(baseDIR,'matlab');
        OETdir=fullfile(AMdir,'OpenEarthTools');
        
    case 'pc-dev'
        baseDIR='D:\Projects\aims-gitlab';
        AODNbaseDir='D:\Projects\aodn';
        AMdir=fullfile(baseDIR,'aims-matlab');
        OETdir=fullfile(baseDIR,'aims-matlab','OpenEarthTools');
        
    case 'hpc'
        baseDIR='/export/ocean/AIMS';
        AODNbaseDir='/export/ocean/AIMS';
        AMdir=fullfile(baseDIR,'matlab');
        OETdir=fullfile(AMdir,'OpenEarthTools');
        
    case 'hpc-dev'
        baseDIR='/export/ocean/sspagnol/src/aims-gitlab';
        AODNbaseDir='/export/ocean/sspagnol/src/github/aodn';
        AMdir='/export/ocean/AIMS/matlab';
        OETdir=fullfile(AMdir,'OpenEarthTools');
        
end

% path to AIMS imos-datatools, needed for getAllFiles etc
ITBdir=fullfile(baseDIR,'imos-toolbox-2.5-aims');

% path to AIMS imos-datatools, needed for getAllFiles etc
IDTdir=fullfile(baseDIR,'imos-datatools');

% path to AIMS Easyplot
EPdir=fullfile(baseDIR,'easyplot');

% path to IMOS user code library
IUCLdir=fullfile(AODNbaseDir,'imos-user-code-library','MATLAB_R2011');

% location of the users toolbox installation
ITBdir='D:\Projects\aims-gitlab\imos-toolbox';

% location of the aims imos datatols installation
IDTdir='D:\Projects\aims-gitlab\imos-datatools';

% user should not need to edit anything further

%%
reAddPaths(EPdir,'AIMS easyplot',true);

%%
reAddPaths(IDTdir,'AIMS imos-datatools',true);

%% add IMOS Toolbox paths
reAddPaths(ITBdir,'IMOS toolbox',true);

end

%%
function reAddPaths(topDir,messageStr,atBeginning)

disp(['Adding paths for ' messageStr ', please wait...']);
gp=genpath_clean(topDir);
disp('  Removing any existing paths.')
rempath(gp);
disp('  Adding new paths');
if atBeginning
    addpath(gp,'-begin');
else
    addpath(gp);
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
function thePath = genpath_clean( topDir )
%genpath_clean generate a path without .svn, .git etc.
%   generate a path without .svn, .git etc. Based on idea from OpenEarthTools

b=genpath(topDir);
s = strread(b, '%s','delimiter', pathsep);  % read path as cell
rpattern='(\.svn|\.git|\.hg\private)';
ii=cellfun(@isempty,regexp(s,rpattern,'match','once'));
s=s(ii); %cell array without .git etc
thePath=sprintf(['%s' pathsep],s{:}); %make string seperated by pathsep
if thePath(end)==pathsep % remove last not needed pathsep
    thePath(end)=[];
end

end