function display(pf,varargin)
% standard output

displayClass(pf,inputname(1));

if isempty_cell(pf.allH), return;end

disp(char(pf.CS,'verbose','symmetryType'));
disp(char(pf.SS,'verbose','symmetryType'));
disp(' ');

for i = 1:pf.numPF
  if ~isempty(pf.select(i))
    disp(['  ',char(pf.select(i),'short')]);
  end
end
