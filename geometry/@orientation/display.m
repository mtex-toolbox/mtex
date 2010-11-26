function display(o)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('orientation_index','orientation') ' (size: ' int2str(size(o)) ')']);

if ~isempty(get(o.CS,'mineral'))
  disp(['  mineral: ',get(o.CS,'mineral')]);
end
  
convention = get(o.CS,'convention');
disp(['  crystal symmetry: ', option2str([{get(o.CS,'name')},convention])]);
disp(['  sample symmetry : ',get(o.SS,'name')]);


if numel(o) < 30 && numel(o)>0
  
  Euler(o);
  
else

  disp(' ');
  
end

