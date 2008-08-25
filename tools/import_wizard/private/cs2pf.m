function pf = cs2pf(pf, handles )

cs = get(handles.crystal,'Value');
cs = symmetries(cs);
cs = strtrim(cs{1}(1:6));
 
for k=1:3 
  axis{k} =  str2double(get(handles.axis{k},'String'));
  angle{k} =  str2double(get(handles.angle{k},'String'));
end

cs = symmetry(cs,[axis{:}],[angle{:}]);
pf = set(pf,'CS',cs);
