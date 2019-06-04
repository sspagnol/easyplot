%%
function plotVar = chooseVar(sample_data)
% CHOOSEVAR Choose single variable to plot
%
% chooseVar is always called after and data import so if this function ends
% up with no data then abort.

if isempty(sample_data)
    error('CHOOSEVAR: empty sample_data');
end

plotVar=[];
varList= {};
for ii=1:numel(sample_data)
    for jj=1:numel(sample_data{ii}.variables)
        if sample_data{ii}.EP_isPlottableVar(jj)
            varList{end + 1}=sample_data{ii}.variables{jj}.name;
        end
    end
end
varList=unique(varList);
for ii=1:numel(varList)
    short_name = char(varList{ii});
    long_name = imosParameters(short_name, 'long_name');
    uom = imosParameters(short_name, 'uom');
    dialogList{ii} = [short_name ' (' long_name ') [' uom ']'];
end
varList{end+1}='ALLVARS';
%disp(sprintf('%s ','Variable list = ',varList{:}));

title = 'Variable to plot?';
prompt = 'Variable List';
defaultanswer = 1;
choice = optionDialog( title, prompt, dialogList, defaultanswer );

pause(0.1);
if isempty(choice), return; end

if strcmp(choice,'ALLVARS') %choosen plot all variables
    plotVar=varList(1:end-1);
else
    ii = strcmp(choice, dialogList);
    plotVar=varList{ii};
end
end
