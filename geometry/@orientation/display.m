function display(o)
% standart output

disp(' ');
disp([inputname(1) ' = ' doclink('orientation_index','orientation') ' (size: ' int2str(size(o)) ')']);

if ~isempty(get(o.CS,'mineral'))
  disp(['  mineral: ',get(o.CS,'mineral')]);
end

disp(['  crystal symmetry: ',get(o.CS,'name')]);
disp(['  sample symmetry : ',get(o.SS,'name')]);


if numel(o) < 30 && numel(o)>0
  
  Euler(o);
  
else

  disp(' ');
  
end

