function [ebsd,alpha] = smooth(ebsd,varargin)
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
%   plot(ebsd_smoothed('indexed'),oM.orientation2color(ebsd_smoothed('indexed').orientations))
%   hold on
%   plot(largeGrains(1).boundary,'linewidth',2)
%   hold off

% generate regular grid
ext = ebsd.extend;
dx = max(ebsd.unitCell(:,1))-min(ebsd.unitCell(:,1));
dy = max(ebsd.unitCell(:,2))-min(ebsd.unitCell(:,2));
[xgrid,ygrid] = meshgrid(linspace(ext(1),ext(2),1+round((ext(2)-ext(1))/dx)),...
  linspace(ext(3),ext(4),1+round((ext(4)-ext(3))/dy))); % ygrid runs first
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

% generate a regular grid for the ebsd data
% set grainId correctly
% set orientation to NaN
%ebsd = fill(ebsd);

% extract data for speed reasons
rot = reshape(ebsd.rotations,sGrid);
rot.a(~ebsd.isIndexed) = NaN;
rot.b(~ebsd.isIndexed) = NaN;
rot.c(~ebsd.isIndexed) = NaN;
rot.d(~ebsd.isIndexed) = NaN;

CSList = ebsd.CSList;

% loop through all grains
grainIds = unique(grainId).';
progress(0,length(grainIds));

% find the largest grain
[~,m] = max(histc(ebsd.grainId,0.5:1:max(ebsd.grainId)+0.5))

% and sort it first
grainIds = [m,grainIds(grainIds~=m)];

alpha = get_option(varargin,'alpha',[]);

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
  notNaN = ~isnan(rot.a(ind));
  if nnz(notNaN)<10 || nRow < 3 || nCol < 3, continue, end
    
  % remove NaN values   
  indLocal = indLocal(notNaN);
  ori = orientation(rot(ind),CSList{2});   
  
  % rotate such that mean is in identity
  [qmean,~,~,~,q] = mean(ori(notNaN));
  q = inv(qmean)*q; %#ok<MINV>
  qgrid = nanquaternion(nRow,nCol);
  qgrid(indLocal) = q;

  % perform local smoothing
  switch get_option(varargin,'filter','spline')
    case 'spline'
      [qgrid,alpha] = splineSmoothing(qgrid,alpha);
    case 'median'
      qgrid = medianFilter(qgrid);
    case 'mean'
      qgrid = meanFilter(qgrid);
    case 'halfquad'
      qgrid = halfQuadraticSmoothing(qgrid,alpha);
    otherwise 
      error('Unknown filter!')
  end
    
  % rotate back
  rot(ind) = quaternion(qmean) * qgrid(indLocal);
    
end

% store to EBSD variable
ebsd.rotations = rot(:);
    
end
  
%mtexdata forsterite
%ebsd = ebsd(inpolygon(ebsd,[5 2 10 5]*10^3));
%[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'))
%grains = smooth(grains)
%oM = ipdfHSVOrientationMapping(ebsd('fo').CS.properGroup)
%oM.inversePoleFigureDirection = Miller(oM.whiteCenter,ebsd('fo').CS.properGroup);
%oM.colorStretching = 7;
%plot(ebsd('fo'),oM.orientation2color(ebsd('fo').mis2mean))
%hold on
%plot(grains.boundary)
%hold off
%figure
%plot(oM)
%ebsd_smoothed = smooth(ebsd)

% [~,id] = max(grains.area)
% ebsd = ebsd(grains(id))
% oM = ipdfHSVOrientationMapping(ebsd('fo').CS.properGroup)
% oM.inversePoleFigureDirection = grains(id).meanOrientation*oM.whiteCenter;
% oM.colorStretching = 7;
% plot(ebsd,oM.orientation2color(ebsd.orientations))
% ebsd_smoothed = smooth(ebsd)
% plot(ebsd_smoothed,oM.orientation2color(ebsd_smoothed.orientations))
