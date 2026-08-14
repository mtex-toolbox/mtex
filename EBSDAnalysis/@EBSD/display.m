function display(ebsd,varargin)
% standard output

displayClass(ebsd,inputname(1),'moreInfo',char(ebsd.how2plot,'compact'));

% empty ebsd set 
if isempty(ebsd)
  disp('  EBSD is empty!')
  return
end

disp(' ')

% ebsd.phaseMap
matrix = cell(0,5);

for ip = 1:numel(ebsd.phaseMap)

  numPhase = nnz(ebsd.phaseId == ip);

  if numPhase == 0, continue; end

  % phase
  matrix{end+1,1} = num2str(ebsd.phaseMap(ip)); %#ok<*AGROW>

  % orientations
  matrix{end,2} = [int2str(numPhase) ' (' xnum2str(100*numPhase./numel(ebsd)) '%)'];
  
  % mineral
  CS = ebsd.CSList(ip);
  % abort in special cases
  if isempty(CS), continue, end

  % mineral
  matrix{end,3} = char(CS.mineral);
  
  % color
  matrix{end,4} = rgb2str(CS.color);

  % symmetry & reference frame
  if CS.isIndexed 
    matrix{end,5} = CS.pointGroup;
    matrix{end,6} = option2str(CS.alignment);
  end

end

cprintf(matrix,'-L',' ','-Lc',...
  {'Phase' 'Orientations' 'Mineral' 'Color' 'Symmetry' 'Crystal reference frame'},...
  '-d','  ','-ic',true);

disp(' ');
if numel(ebsd)<=20
  disp(char(dynProp(ebsd.prop),'Id',ebsd.id,'Phase',reshape(ebsd.phase,size(ebsd)),...
    'orientation',ebsd.rotations));
else
  disp(char(dynProp(ebsd.prop)));
end
disp(strong(" Scan unit") + " : " + ebsd.scanUnit);

% an EBSD may hold measurements and yet no positions - a damaged file, or
% one written by a version that stored them elsewhere. extent is empty
% then, so ext(1:2) would throw and the display would be the thing that
% breaks on the very object one is trying to look at
if isempty(ebsd.pos)
  disp(strong(" X x Y x Z") + " : none, this EBSD has no positions");
else
  ext = ebsd.extent;
  disp(strong(" X x Y x Z") + " : [" + xnum2str(ext(1:2),'delimiter',' → ') + "] x [" + ...
    xnum2str(ext(3:4),'delimiter',' → ') + "] x [" + xnum2str(ext(5:6),'delimiter',' → ') + "]");
end
disp(strong(" Normal vector") + ": (" + ...
  char(round(ebsd.N,'accuracy',5*degree)) + ")");

if min(ebsd.size) > 1
  if length(ebsd.unitCell) == 6
    disp(strong(" Hex grid") + "     :" + size2str(ebsd));
  else
    disp(strong(" Square grid") + "  :" + size2str(ebsd));
  end
end

% display all other options
dispStruct(ebsd.opt);

disp(' ');

end