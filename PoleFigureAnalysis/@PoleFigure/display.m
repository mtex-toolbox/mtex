function display(pf,varargin)
% standard output

% the crystal symmetry and the specimen frame with its convention, as an
% orientation shows them; a non trivial specimen symmetry keeps its point group
info = [char(pf.CS,'compact') ' ' getMTEXpref('arrowChar') ' ' ...
  referenceFrame.headerChar(pf.frame,pf.how2plot)];
if pf.SS.id > 1, info = [info ' (' pf.SS.pointGroup ')']; end
displayClass(pf,inputname(1),'moreInfo',info,varargin{:});

if isempty_cell(pf.allH), return;end

disp(char(pf.CS,'verbose','symmetryType'));
disp(' ');

for i = 1:pf.numPF
  if ~isempty(pf.select(i))
    disp(['  ',char(pf.select(i),'short')]);
  end
end
