function [ebsd,filter,filledId] = smooth(ebsd,varargin)
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

% some interpolation
if check_option(varargin,'fill')
  F = TriScatteredInterp([ebsd.prop.x(:),ebsd.prop.y(:)],(1:length(ebsd.prop.x)).','nearest'); %#ok<DTRIINT>
  idOld = fix(F(xgrid(:),ygrid(:)));

  filledId = true(sGrid);
  filledId(ind) = false;
  
  % interpolate phaseId
  ebsd.phaseId = reshape(ebsd.phaseId(idOld),[],1);
  
  % interpolate grainId
  if isfield(ebsd.prop,'grainId')
    grainId = reshape(ebsd.prop.grainId(idOld),sGrid);
    ebsd.prop.grainId = grainId(:);
  else
    grainId = ebsd.phaseId(idOld);
  end
else
  % set phaseId to notIndexed at all empty grid points
  phaseId = ones(sGrid);
  phaseId(ind) = ebsd.phaseId;
  ebsd.phaseId = phaseId(:);
  
  if isfield(ebsd.prop,'grainId')
    grainId = zeros(sGrid);
    grainId(ind) = ebsd.grainId;
    ebsd.prop.grainId = grainId(:);
  else
    grainId = phaseId;
  end
  
  clear phaseId  
end

% update spatial coordiantes
ebsd.prop.x = xgrid(:);
ebsd.prop.y = ygrid(:);
ebsd.id = (1:numel(xgrid)).';
clear xgrid ygrid

% update rotations
a = nan(sGrid); b = a; c = a; d = a;
a(ind) = ebsd.rotations.a;
b(ind) = ebsd.rotations.b;
c(ind) = ebsd.rotations.c;
d(ind) = ebsd.rotations.d;
ebsd.rotations = reshape(rotation(quaternion(a,b,c,d)),[],1);
clear a b c d

% delete all other properties
for fn = fieldnames(ebsd.prop).'
  if any(strcmp(char(fn),{'x','y','z','grainId'})), continue;end
  ebsd.prop = rmfield(ebsd.prop,fn);  
end


% extract data for speed reasons
rot = reshape(ebsd.rotations,sGrid);
rot.a(~ebsd.isIndexed) = NaN;
rot.b(~ebsd.isIndexed) = NaN;
rot.c(~ebsd.isIndexed) = NaN;
rot.d(~ebsd.isIndexed) = NaN;

CSList = ebsd.CSList;

% loop through all grains
[grainIds,pos] = unique(grainId);
phaseIds = ebsd.phaseId(pos).';
grainIds = grainIds.';
progress(0,length(grainIds));

% find the largest grain
[~,m] = max(histc(grainId(:),0.5:1:max(grainId)+0.5));

% and sort it first
if m>1
  phaseIds = [phaseIds(grainIds==m),phaseIds(grainIds~=m)];
  grainIds = [m,grainIds(grainIds~=m)];
end

filter = getClass(varargin,'EBSDFilter',splineFilter);

for id = 1:length(grainIds)

  progress(id,length(grainIds));
  
  % the values to be smoothed
  ind = grainId == grainIds(id); 
  
  if ~any(ind(:)), continue; end
  % check all the vertices are inside the grain
  % checkNaN = ind & isnan(rot.a);
          
  % local coordinates in a local rectangular grid
  [irow,icol] = find(ind);
  minCol = min(icol); nCol = 1 + max(icol) - minCol;
  minRow = min(irow); nRow = 1 + max(irow) - minRow;
  indLocal = sub2ind([nRow,nCol],irow - minRow + 1,icol - minCol + 1);
    
  % skip small grains
  if nnz(ind)<5 || nRow < 2 || nCol < 2 || all(isnan(rot(ind).a)), continue, end
  %if all(isnan(rot(ind).a)), continue, end  
  
  %phaseId = ebsd.phaseId(ind);
  %if ischar(CSList{phaseId(1)}), continue; end
  
  ori = orientation(nanquaternion(nRow,nCol),CSList{phaseIds(id)});
  ori(indLocal) = rot(ind);
    
  % perform smoothing
  ori = filter.smooth(ori);
      
  % rotate back
  rot(ind) = ori(indLocal);
    
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
