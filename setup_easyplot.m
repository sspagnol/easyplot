function setup_easyplot

% path to easyplot dir
easyplotDir='C:\prj\GitLab\easyplot';

% location of the users toolbox installation
imos_tb_home='C:\Projects\aims-gitlab\imos-toolbox-2.3b-sbs';

% user should not need to edit anything further

disp('Adding easyplot, please wait ...');
disp(['Easyplot path : ' easyplotDir]);
gp=genpath_clean(easyplotDir);
addpath(gp);

% add all folders and subfolders in imos_tb_home to the path
disp('Adding IMOS-toolbox, please wait ...');
disp(['IMOS-toolbox path : ' imos_tb_home]);
gp=genpath_clean(imos_tb_home);
addpath(gp);

end

%%
function thePath = genpath_clean( topDir )
%genpath_clean generate a path without .svn, .git etc.
%   generate a path without .svn, .git etc. Based on idea from OpenEarthTools

b=genpath(topDir);
s = strread(b, '%s','delimiter', pathsep);  % read path as cell
rpattern='(\.svn|\.git|\.hg)';
ii=cellfun(@isempty,regexp(s,rpattern,'match','once'));
s=s(ii); %cell array without .git etc
thePath=sprintf(['%s' pathsep],s{:}); %make string seperated by pathsep
if thePath(end)==pathsep % remove last not needed pathsep
    thePath(end)=[];
end

end