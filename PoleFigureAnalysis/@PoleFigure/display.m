function display(pf,varargin)
% standard output

% the specimen frame together with the convention; a non trivial
% specimen symmetry keeps its point group
info = referenceFrame.headerChar(pf.frame,pf.how2plot,pf.allR{1}.how2plotPrivate);
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
