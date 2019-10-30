function v = plotS2Grid(varargin)
% create a regular S2Grid for plotting
%
% Syntax
%   plotS2Grid('resolution',[5*degree 2.5*degree])
%
% Options
%  resolution - resolution in polar and azimthal direction
%  hemisphere - 'lower', 'uper', 'complete', 'sphere', 'identified'
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

% get resolution
res = get_option(varargin,'resolution',1*degree);

[rhoMin,rhoMax] = rhoRange(sR);
rho = linspace(rhoMin(1),rhoMax(1),round(1+(rhoMax(1)-rhoMin(1))/res));
for i = 2:length(rhoMin)
  rho = [rho,nan,linspace(rhoMin(i),rhoMax(i),round(1+(rhoMax(i)-rhoMin(i))/res))]; %#ok<AGROW>
end

[thetaMin,thetaMax] = thetaRange(sR,rho);

% remove values out of region
ind = (thetaMax > 1e-5) & (thetaMin < pi - 1e-5);

ind(end) = ind(end-1); ind(1) = ind(2);

% we should put some nans to seperate regions
rho(diff(ind) == 1) = nan;
ind(diff(ind) == 1) = true;

rho(~ind) = []; thetaMin(~ind) = []; thetaMax(~ind) = [];

if isempty(rho)
  v = vector3d;
  theta = [];
else

  % generate grid
  dtheta = thetaMax - thetaMin;
  % ensure an odd number of points to have some points at the equator
  ntheta = max(3,2*round(max(dtheta./res./2))+1);

  theta = linspace(0,1,ntheta).' * dtheta + repmat(thetaMin,ntheta,1);

  rho = repmat(rho,ntheta,1);

  v = vector3d('theta',theta,'rho',rho);
end

v = v.setOption('plot',true,'resolution',res,'region',sR,'theta',theta,'rho',rho);

end
