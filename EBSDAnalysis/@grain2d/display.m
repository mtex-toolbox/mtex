function  display(grains,varargin)
% standard output

displayClass(grains,inputname(1),'moreInfo',...
  referenceFrame.headerChar(grains.frame,grains.how2plot));

disp(' ')
%disp(char(dynOption(grains)));

% generate phase table
matrix = cell(numel(grains.phaseMap),6);

for ip = 1:numel(grains.phaseMap)
  
  ind = grains.phaseId == ip;
  
  % phase
  matrix{ip,1} = num2str(grains.phaseMap(ip)); %#ok<*AGROW>
  
  % grains
  matrix{ip,2} = int2str(nnz(ind));
  
  % grains
  matrix{ip,3} = int2str(sum(grains.numPixel(ind)));
  
  CS = grains.CSList(ip);

  % abort in special cases
  if isempty(CS), continue; end
  
  % mineral
  matrix{ip,4} = char(CS.mineral);
  
  % color
  matrix{ip,6} = rgb2str(CS.color);
  
  % symmetry
  if isa(CS,'symmetry'), matrix{ip,5} = CS.pointGroup; end

  % reference frame
  %matrix{ip,6} = option2str(CS.alignment);
  
end

% remove empty rows
matrix(accumarray(full(grains.phaseId),1,[size(matrix,1) 1])==0,:) = [];

if ~isempty(grains)
  cprintf(matrix,'-L',' ','-Lc',...
    {'Phase' 'Grains' 'Pixels' 'Mineral'  'Symmetry' 'Color'},...
    '-d','  ','-ic',true);
else
  disp('  no grains here!')
end

disp(' ')

% show boundary and triple points
su = strrep(grains.scanUnit,'um','µm');
disp([' ' varlink([inputname(1),'.boundary'],'boundary segments') ': ', ...
  int2str(length(grains.boundary)) ...
  ' (' xnum2str(sum(grains.boundary.segLength)) ' ' su ')'])
disp([' ' varlink([inputname(1),'.innerBoundary'],'inner boundary segments') ': ', ...
  int2str(length(grains.innerBoundary)) ...
  ' (' xnum2str(sum(grains.innerBoundary.segLength)) ' ' su ')'])
disp([' ' varlink([inputname(1),'.triplePoints'],'triple points') ': ',int2str(length(grains.triplePoints))])
disp(' ');

if isempty(grains), return; end

% show properties
disp(char(dynProp(grains.prop),...
  'Id',grains.id,'Phase',grains.phase,'Pixels',grains.numPixel))
disp(' ')
