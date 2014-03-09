function v = plotS2Grid(varargin)
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
%  antipodal  - include <AxialDirectional.html antipodal symmetry>
%  restrict2MinMax - restrict margins to min / max
%
% See also
% equispacedS2Grid regularS2Grid


% get spherical region
%sR = getPolarRange(varargin{:});
if isa(varargin{1},'sphericalRegion')
  sR = varargin{1};
else
  sR = sphericalRegion(varargin{:});
end
  
% TODO: extractoptions 'antipodal','lower','upper'

% get resolution
res = get_option(varargin,'resolution',1*degree);

[rhoMin,rhoMax] = rhoRange(sR);
rho = linspace(rhoMin,rhoMax,round(1+(rhoMax-rhoMin)/res));

[thetaMin,thetaMax] = thetaRange(sR,rho);

% remove values out of region
ind = (thetaMax > 1e-5) & (thetaMin < pi - 1e-5);

ind(end) = ind(end-1); ind(1) = ind(2);

rho(~ind) = []; thetaMin(~ind) = []; thetaMax(~ind) = [];


% generate grid
dtheta = thetaMax - thetaMin;
ntheta = round(max(dtheta./res));

theta = linspace(0,1,ntheta).' * dtheta + repmat(thetaMin,ntheta,1);

rho = repmat(rho,ntheta,1);

v = sph2vec(theta,rho);

v = v.setOption('plot',true,'resolution',res,'region',sR);



end
