function display(o)
% standart output

csss = {'sample symmetry ','crystal symmetry'};

disp(' ');
s = [inputname(1) ' = '];
if ~isa(o.SS,'symmetry') || ~isa(o.CS,'symmetry')
  s = [s 'invalid misorientation'];
  disp(s);
  disp(['  size: ' size2str(o)]);
  return
elseif isMisorientation(o)
  s = [s doclink('orientation_index','misorientation')];
elseif isCS(o.SS)
  s = [s doclink('orientation_index','inverse orientation')];  
else
  s = [s doclink('orientation_index','orientation')];
end
  
disp([s ' ' docmethods(inputname(1))]);

disp(['  size: ' size2str(o)]);
disp(['  ' csss{isCS(o.CS)+1} ': ', char(o.CS,'verbose')]);
disp(['  ' csss{isCS(o.SS)+1} ': ',char(o.SS,'verbose')]);

if numel(o) < 30 && numel(o)>0, Euler(o);end

disp(' ')
