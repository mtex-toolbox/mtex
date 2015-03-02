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
dx = ebsd.unitCell(1,1)-ebsd.unitCell(4,1);
dy = ebsd.unitCell(1,2)-ebsd.unitCell(2,2);
[xgrid,ygrid] = meshgrid(ext(1):dx:ext(2),ext(3):dy:ext(4)); % ygrid runs first

% detect position within grid
xpos = 1 + round((ebsd.prop.x - ext(1))/dx);
ypos = 1 + round((ebsd.prop.y - ext(3))/dy);

% compute components in Lie algebra
[qmean,~,~,~,q] = mean(ebsd.orientations);
q = inv(qmean)*q; %#ok<MINV>
tq = log(q);

% fill interpolation matrix
Tq = nan(numel(xgrid),3);
Tq(sub2ind(size(xgrid),ypos,xpos),:) = tq;
Tq = reshape(Tq,[size(xgrid),3]);

% perform smoothing
if nargin < 2, alpha = []; end
[T,alpha] = smoothn({Tq(:,:,1),Tq(:,:,2),Tq(:,:,3)},alpha,'robust');

% fill ebsd variable
ebsd.prop.x = xgrid(:);
ebsd.prop.y = ygrid(:);
ebsd.id = (1:numel(xgrid)).';
ebsd.rotations = reshape(rotation(quaternion(qmean)*expquat([T{:}])),[],1);
ebsd.phaseId = repmat(ebsd.phaseId(1),numel(xgrid),1);

% delete all other properties
for fn = fieldnames(ebsd.prop).'
  if any(strcmp(char(fn),{'x','y','z'})), continue;end
  ebsd.prop = rmfield(ebsd.prop,fn);  
end
