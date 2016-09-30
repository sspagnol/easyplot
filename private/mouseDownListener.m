%%
function mouseDownListener(hObject,eventdata); %hObject, eventdata

% set re-entrancy flag
persistent hash;
if isempty(hash)
    hash = java.util.Hashtable;
end
if ~isempty(hash.get(hObject))
    return;
end
hash.put(hObject,1);

%     switch lower(selType)
%         case 'normal'
%             disp('Left Click');
%         case 'extend'
%             disp('Shift - click left mouse button or click both left and right mouse buttons');
%         case 'alt'
%             disp('Control - click left mouse button or click right mouse button.');
%         case 'open'
%             disp('Double-click any mouse button')
%         otherwise
%             disp(selType)
%     end %switch

switch lower(get(hObject, 'SelectionType'))
    case 'extend'
        printInfo(hObject, eventdata);
end

% release rentrancy flag
hash.remove(hObject);

end

