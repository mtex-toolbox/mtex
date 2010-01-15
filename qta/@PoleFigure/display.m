function display(pf,varargin)
% standard output

disp(' ');
h = doclink('PoleFigure_index','PoleFigure');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

disp(h);
disp(['  symmetry: ' char(pf(1).CS) ' - ' char(pf(1).SS)]);
for i = 1:length(pf)
  disp(['  ',char(pf(i),'short')]);
end
disp(' ');
