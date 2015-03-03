function setup_easyplot

% path to easyplot dir
[EPdir, name, ext] = fileparts(mfilename('fullpath'));
%easyplotDir='D:\Projects\aims-gitlab\easyplot';

% location of the users toolbox installation
imos_tb_home='c:\Projects\aims-gitlab\imos-toolbox-aims';

% user should not need to edit anything further

%%
reAddPaths(EPdir,'AIMS easyplot',true);

%% add IMOS Toolbox paths
reAddPaths(imos_tb_home,'IMOS toolbox',true);

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