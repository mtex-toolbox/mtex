function display(tP,varargin)
% standard output
%
%  id  | mineralLeft | mineralRight
% ---------------------------------
%
% #ids | mineralLeft | mineralRight
% ---------------------------------

displayClass(tP,inputname(1),'moreInfo',...
  referenceFrame.headerChar(tP.frame,tP.how2plot));

% empty grain boundary set 
if isempty(tP)
  disp('  no triple points in the list!')
  return
end

disp(' ')

triple = allTriple(1:numel(tP.phaseMap));

% ebsd.phaseMap
matrix = cell(size(triple,1),4);


for ip = 1:size(triple,1)

  num(ip) = nnz(tP.hasPhaseId(triple(ip,1),triple(ip,2),triple(ip,3))); %#ok<AGROW>
  matrix{ip,1} = int2str(num(ip));
  
  % phases
  matrix{ip,2} = tP.CSList(triple(ip,1)).mineral;
  matrix{ip,3} = tP.CSList(triple(ip,2)).mineral;
  matrix{ip,4} = tP.CSList(triple(ip,3)).mineral;
  
end
matrix(num==0,:) = [];


cprintf(matrix,'-L',' ','-Lc',...
  {'points' 'mineral 1' 'mineral 2' 'mineral 3'},'-d','  ','-ic',true);

%disp(' ');
%disp(char(dynProp(gB.prop)));
%disp(' ');
