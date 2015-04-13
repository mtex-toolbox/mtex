function [ebsd,alpha] = smooth(ebsd,alpha)
% smooth spatial EBSD 
%
% Input
%  ebsd - @EBSD
%
% Example
%   mtexdata forsterite
%   ebsd = ebsd('indexed');
%   % segment grains
%   [grains,ebsd.grainId] = calcGrains(ebsd)
%
%   % find largest grains
%   largeGrains = grains(grains.grainSize>800)
%   ebsd = ebsd(largeGrains(1))
%
%   figure
%   plot(largeGrains(1).boundary,'linewidth',2)
%   hold on
%   oM = ipdfHSVOrientationMapping(ebsd);
%   oM.inversePoleFigureDirection = mean(ebsd.orientations) * oM.whiteCenter;
%   oM.colorStretching = 50;
%   plot(ebsd,oM.orientation2color(ebsd.orientations))
%   hold off
%
%   ebsd_smoothed = smooth(ebsd)
%   plot(ebsd_smoothed,oM.orientation2color(ebsd_smoothed.orientations))
%   hold on
%   plot(largeGrains(1).boundary,'linewidth',2)
%   hold off

% generate regular grid
ext = ebsd.extend;
dx = max(ebsd.unitCell(:,1))-min(ebsd.unitCell(:,1));
dy = max(ebsd.unitCell(:,2))-min(ebsd.unitCell(:,2));
[xgrid,ygrid] = meshgrid(ext(1):dx:ext(2),ext(3):dy:ext(4)); % ygrid runs first
sGrid = size(xgrid);

% detect position within grid
ind = sub2ind(sGrid, 1 + round((ebsd.prop.y - ext(3))/dy), ...
  1 + round((ebsd.prop.x - ext(1))/dx));

ebsd.prop.x = xgrid(:);
ebsd.prop.y = ygrid(:);
ebsd.id = (1:numel(xgrid)).';
clear xgrid ygrid

% the rotations
a = nan(sGrid); b = a; c = a; d = a;
a(ind) = ebsd.rotations.a;
b(ind) = ebsd.rotations.b;
c(ind) = ebsd.rotations.c;
d(ind) = ebsd.rotations.d;
ebsd.rotations = reshape(rotation(quaternion(a,b,c,d)),[],1);
clear a b c d

% the grainIds
grainId = zeros(sGrid);
if isprop(ebsd,'grainId'), grainId(ind) = ebsd.grainId; end
ebsd.prop.grainId = grainId(:);

% the phaseId
phaseId = zeros(numel(ebsd.id),1);
phaseId(ind) = ebsd.phaseId;
ebsd.phaseId = phaseId;
clear phaseId

% delete all other properties
for fn = fieldnames(ebsd.prop).'
  if any(strcmp(char(fn),{'x','y','z','grainId'})), continue;end
  ebsd.prop = rmfield(ebsd.prop,fn);  
end

% ---------------------------------

if nargin < 2, alpha = []; end

% generate a regular grid for the ebsd data
% set grainId correctly
% set orientation to NaN
%ebsd = fill(ebsd);

% extract data for speed reasons
rot = reshape(ebsd.rotations,sGrid);

CSList = ebsd.CSList;

% loop through all grains
grainIds = unique(grainId).';
progress(0,length(grainIds));
for id = grainIds

  progress(id,length(grainIds));
  
  % the values to be smoothed
  ind = grainId == id;
        
  % local coordinates in a local rectangular grid
  [irow,icol] = find(ind);
  minCol = min(icol); nCol = 1 + max(icol) - minCol;
  minRow = min(irow); nRow = 1 + max(irow) - minRow;
  indLocal = sub2ind([nRow,nCol],irow - minRow + 1,icol - minCol + 1);
    
  % skip small grains
  if nRow < 3 || nCol < 3, continue, end
    
  % remove NaN values 
  notNaN = ~isnan(rot.a(ind));
  indLocal = indLocal(notNaN);
  ori = orientation(rot(ind),CSList{2});   
  
  % compute components in the Lie algebra
  [qmean,~,~,~,q] = mean(ori(notNaN));
  q = inv(qmean)*q; %#ok<MINV>  
  tq1 = NaN(nCol,nRow); tq2 = tq1; tq3 = tq1;
  tq = log(q);
  tq1(indLocal) = tq(:,1);
  tq2(indLocal) = tq(:,2);
  tq3(indLocal) = tq(:,3);
    
  % perform smoothing
  [T,alpha] = smoothn({tq1,tq2,tq3},alpha,'robust');

  rot(minRow + (0:nRow-1),minCol + (0:nCol-1)) = ...
    reshape(rotation(quaternion(qmean)*expquat([T{:}])),nRow,nCol);
  
end

% store to EBSD variable
ebsd.rotations = rot;
    
end
  