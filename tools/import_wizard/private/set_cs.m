function object = set_cs(object, handles )
% set cs in object (pf/ebsd)

cs = get(handles.crystal,'Value');
cs = symmetries(cs);
cs = strtrim(cs{1}(1:6));
 
for k=1:3 
  axis{k} =  str2double(get(handles.axis{k},'String'));
  angle{k} =  str2double(get(handles.angle{k},'String'));
end

cs = symmetry(cs,[axis{:}],[angle{:}]);
object = set(object,'CS',cs);
