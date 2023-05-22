function display(gB,varargin)
% standard output
%

displayClass(gB,inputname(1));

% empty grain boundary set 
if isempty(gB)
  disp('  grain boundary is empty!')
  return
end

disp(' ')

% create combinations of phasesIds
[ph1,ph2] = meshgrid([0,gB.indexedPhasesId]);

% initialize output
matrix = cell(numel(ph2),3);
num = zeros(numel(ph2),1);

% store phaseId in phId and set all notIndexed ids to 0
phId = gB.phaseId;
phId(~ismember(phId,gB.indexedPhasesId)) = 0;

su = strrep(gB.scanUnit,'um','µm');

% run through all phase combinations
for ip = 1:numel(ph2)

  % the number of boundary segments where both phases fit
  cond = phId(:,1) == ph1(ip) & phId(:,2) == ph2(ip);
  num(ip) = sum(cond);
  
  % store the number as string
  matrix{ip,1} = int2str(num(ip));

  matrix{ip,2} = [xnum2str(sum(gB.segLength(cond))) ' ' su];

  % phases
  if ph1(ip) == 0
    matrix{ip,3} = 'notIndexed';
  else
    matrix{ip,3} = gB.CSList{ph1(ip)}.mineral;
  end
  if ph2(ip)==0
    matrix{ip,4} = 'notIndexed';
  else
    matrix{ip,4} = gB.CSList{ph2(ip)}.mineral;
  end

end
matrix(num==0,:) = [];

cprintf(matrix,'-L',' ','-Lc',...
  {'Segments' 'length' 'mineral 1' 'mineral 2'},'-d','  ','-ic',true);

%disp(' ');
%disp(char(dynProp(gB.prop)));
%disp(' ');
