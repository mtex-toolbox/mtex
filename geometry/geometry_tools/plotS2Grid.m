function v = plotS2Grid(varargin)
% create a regular S2Grid for plotting
%
% Syntax
%   plotS2Grid('resolution',[5*degree 2.5*degree])
%
%   % a grid of directions of the crystal reference frame
%   plotS2Grid('resolution',0.5*degree,'upper',cs.frame)
%
% Input
%  frame - @referenceFrame the resulting directions are expressed in
%
% Options
%  resolution - resolution in polar and azimuthal direction
%  hemisphere - 'lower', 'upper', 'complete', 'sphere', 'identified'
%  minRho     - starting rho angle (default 0)
%  maxRho     - maximum rho angle (default 2*pi)
%  minTheta   - starting theta angle (default 0)
%  maxTheta   - maximum theta angle (default pi)
%
% Flags
%  antipodal  - include <VectorsAxes.html antipodal symmetry>
%  restrict2MinMax - restrict margins to min / max
%
% See also
% equispacedS2Grid regularS2Grid

% get spherical region
sR = extractSphericalRegion(varargin{:});

% get plotting convention
if check_option(varargin,'plain')
  rot = rotation.id;
else

  pC = getClass(varargin,'plottingConvention',sR.how2plot);

  % rotate sR it such that pC.outOfPlane points to z
  rot = rotation.map(pC.outOfScreen,zvector);
end

sRRot = rot*sR;

% get resolution
res = get_option(varargin,'resolution',1*degree);

[rhoMin,rhoMax] = rhoRange(sRRot);
rho = linspace(rhoMin(1),rhoMax(1),round(1+(rhoMax(1)-rhoMin(1))/res));
for i = 2:length(rhoMin)
  rho = [rho,nan,linspace(rhoMin(i),rhoMax(i),round(1+(rhoMax(i)-rhoMin(i))/res))]; %#ok<AGROW>
end

% the polar angles need not form a single interval, so assemble the grid from strips
[thetaMin,thetaMax] = thetaIntervals(sRRot,rho);
[rho,thetaMin,thetaMax] = buildStrips(rho,thetaMin,thetaMax);

if isempty(rho)
  v = vector3d; theta = [];
else
  [theta,rho] = fillStrips(thetaMin,thetaMax,rho,res);
  v = vector3d.byPolar(theta,rho);
end

% rotate back
v = inv(rot) .* v;

% the grid consists of directions of the frame the region is given in
v.frame = sR.frame;

v = v.setOption('plot',true,'resolution',res,'region',sR,'theta',theta,'rho',rho);

end

% ------------------------------------------------------------------------

function [a,bMin,bMax] = buildStrips(a,bMin,bMax)
% split a region given as intervals [bMin,bMax] over the grid lines a into
% strips of one interval per grid line, separated by NaN
%
% bMin, bMax are nInt × numel(a) and padded with NaN. Where an interval
% splits in two, or two merge into one, the strips share that grid line, so
% that the cells between them are drawn as well.

% an interval collapsed onto a pole is no region, it would glue all strips together
degenerated = (bMax < 1e-5) | (bMin > pi - 1e-5);

% at the first and the last grid line a sector may legitimately close in a
% vertex - keep those, so that the grid extends up to it
if size(degenerated,2) > 1
  degenerated(1,1) = degenerated(1,2);
  degenerated(1,end) = degenerated(1,end-1);
end

valid = ~isnan(bMin) & ~degenerated;
todo = valid;
[nInt,nA] = size(todo);

aOut = []; minOut = []; maxOut = [];
while any(todo(:))

  % start a new strip at the first interval not yet used
  [j,i] = ind2sub([nInt,nA],find(todo,1));
  sA = a(i); sMin = bMin(j,i); sMax = bMax(j,i);
  todo(j,i) = false;

  % where it branches off another strip, share that grid line
  if i > 1
    j = find(valid(:,i-1) & bMin(:,i-1) <= sMax & bMax(:,i-1) >= sMin,1);
    if ~isempty(j)
      sA = [a(i-1),sA]; sMin = [bMin(j,i-1),sMin]; sMax = [bMax(j,i-1),sMax];
    end
  end

  % and follow it along the grid lines as long as the intervals overlap,
  % one line into a strip already built where the two join
  while i < nA
    j = find(valid(:,i+1) & bMin(:,i+1) <= sMax(end) & ...
      bMax(:,i+1) >= sMin(end),1);
    if isempty(j), break; end
    i = i + 1;
    sA(end+1) = a(i); %#ok<AGROW>
    sMin(end+1) = bMin(j,i); %#ok<AGROW>
    sMax(end+1) = bMax(j,i); %#ok<AGROW>
    if ~todo(j,i), break; end
    todo(j,i) = false;
  end

  if isempty(aOut)
    aOut = sA; minOut = sMin; maxOut = sMax;
  else
    aOut = [aOut,NaN,sA]; %#ok<AGROW>
    minOut = [minOut,NaN,sMin]; %#ok<AGROW>
    maxOut = [maxOut,NaN,sMax]; %#ok<AGROW>
  end
end

a = aOut; bMin = minOut; bMax = maxOut;

end

% ------------------------------------------------------------------------

function [b,a] = fillStrips(bMin,bMax,a,res)
% discretize the intervals [bMin,bMax] of every grid line a

db = bMax - bMin;

% ensure an odd number of points to have some points at the equator
nb = max(3,2*round(max(db./res./2))+1);

b = linspace(0,1,nb).' * db + repmat(bMin,nb,1);
a = repmat(a,nb,1);

end
