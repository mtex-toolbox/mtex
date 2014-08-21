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

disp(char(pf.CS,'verbose','symmetryType'));
disp(char(pf.SS,'verbose','symmetryType'));
disp(' ');

for i = 1:pf.numPF
  if ~isempty(pf.select(i))
    disp(['  ',char(pf.select(i),'short')]);
  end
end
