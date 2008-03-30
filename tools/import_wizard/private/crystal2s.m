function pfsa = crystal2s( pfsa, handles )

cs = get(handles.crystal,'Value');
cs = symmetries(cs);
cs = strtrim(cs{1}(1:6));
 
for k=1:3 
  axis{k} =  str2double(get(handles.axis{k},'String'));
  angle{k} =  str2double(get(handles.angle{k},'String'));
end

cs = symmetry(cs,[axis{:}],[angle{:}]);
pfsa = set(pfsa,'CS',cs);

ss = symmetries(get(handles.specime,'Value'));
ss = strtrim(ss{1}(1:6));
ss = symmetry(ss);
pfsa = set(pfsa,'SS',ss);