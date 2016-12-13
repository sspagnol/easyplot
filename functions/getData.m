%%
function table_data = getData(jtable_handle)
%getData : Get data from jtable Table

numrows = jtable_handle.getRowCount;
numcols = jtable_handle.getColumnCount;

table_data = cell(numrows, numcols);

for n = 1 : numrows
    for m = 1 : numcols
        %[n,m]
        temp_data = jtable_handle.getValueAt(n-1, m-1); % java indexing
        if isempty(temp_data)
            table_data{n,m} = '';
        else
            table_data{n,m} = temp_data;
        end
    end
end

end % function getData

