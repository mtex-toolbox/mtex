function id = pushTemp(obj)

tmp = getappdata(0,'tmpData');

if isempty(tmp)
  tmp.data = {};
  id = 1;
else 
  id = mod(tmp.id, 20) + 1;
end

tmp.id = id; 
s = whos('obj');
if s.bytes < 10000000
  tmp.data{id} = obj;
else 
  tmp.data{id} = 'too large to display';
end  
setappdata(0,'tmpData',tmp);


end