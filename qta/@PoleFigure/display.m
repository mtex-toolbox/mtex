function display(pf,varargin)
% standard output

disp(' ');
h = doclink('PoleFigure_index','PoleFigure');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

s = [' ('];
for i=1:length(pf)
 s = [s, pf(i).comment];
 if i~=length(pf), s = [s ', ']; end
end
 length(s)
if length(s) > 60
 h = [h, s(1:60) '...'];
else
  h = [h,s];
end
h = [h,')'];

disp(h);
disp(['  symmetry: ' char(pf(1).CS) ' - ' char(pf(1).SS)]);
for i = 1:length(pf)
  disp(['  ',char(pf(i),'short')]);
end
disp(' ');
