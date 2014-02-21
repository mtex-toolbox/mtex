function display(pf,varargin)
% standard output

disp(' ');
h = doclink('PoleFigure_index','PoleFigure');

if check_option(varargin,'vname')
  h = [get_option(varargin,'vname'), ' = ' h];
elseif ~isempty(inputname(1))
  h = [inputname(1), ' = ' h];
end;

disp([h ' ' docmethods(inputname(1))]);

if isempty_cell(pf.allH), return;end

% display mineral name
if ~isempty(pf.CS.mineral)
  disp(['  mineral: ',pf.CS.mineral]);
end

disp(['  crystal symmetry : ',char(pf.CS,'verbose')]);
disp(['  specimen symmetry: ',char(pf.SS,'verbose')]);
disp(' ');

for i = 1:pf.numPF
  disp(['  ',char(pf.select(i),'short')]);
end
