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
matrix = cell(numel(ebsd.phaseMap),5);
for ip = 1:numel(ebsd.phaseMap)

  % phase
  matrix{ip,1} = num2str(ebsd.phaseMap(ip)); %#ok<*AGROW>

  % orientations
  numPhase = nnz(ebsd.phaseId == ip);
  matrix{ip,2} = [int2str(numPhase) ' (' xnum2str(100*numPhase./numel(ebsd.phase)) '%)'];
  
    % mineral
  CS = ebsd.CSList{ip};
  % abort in special cases
  if isempty(CS)
    continue
  elseif ischar(CS)
    matrix{ip,3} = CS;  
    continue
  else
    matrix{ip,3} = char(CS.mineral);
  end

  % color
  matrix{ip,4} = rgb2str(CS.color);
  
  % symmetry
  matrix{ip,5} = CS.pointGroup;

  % reference frame
  matrix{ip,6} = option2str(CS.alignment);

end

% remove empty rows
matrix(accumarray(ebsd.phaseId(ebsd.phaseId>0),1,[size(matrix,1) 1])==0,:) = [];

cprintf(matrix,'-L',' ','-Lc',...
  {'Phase' 'Orientations' 'Mineral' 'Color' 'Symmetry' 'Crystal reference frame'},...
  '-d','  ','-ic',true);

disp(' ');
disp(char(dynProp(ebsd.prop),'Id',ebsd.id,'Phase',reshape(ebsd.phase,size(ebsd)),...
  'orientation',ebsd.rotations));
disp(strong(" Scan unit") + " : " + ebsd.scanUnit);
ext = ebsd.extent;
disp(strong(" X x Y x Z") + " : [" + xnum2str(ext(1:2),'delimiter',', ') + "] x [" + ...
  xnum2str(ext(3:4),'delimiter',', ') + "] x [" + xnum2str(ext(5:6),'delimiter',', ') + "]");
disp(strong(" Normal vector") + ": (" + ...
  char(round(ebsd.N,'accuracy',5*degree)) + ")");

if min(ebsd.size) > 1
  if size(ebsd.unitCell,1) == 6
    disp(strong(" Hex grid") + "     :" + size2str(ebsd));
  else
    disp(strong(" Square grid") + "  :" + size2str(ebsd));
  end
end

% display all other options
dispStruct(ebsd.opt);

disp(' ');

end