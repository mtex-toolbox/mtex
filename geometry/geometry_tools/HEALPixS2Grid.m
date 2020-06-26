function S2G = HEALPixS2Grid(varargin)
% defines an equispaced spherical grid
%
% Syntax
%   equispacedS2Grid('points',300)
%   equispacedS2Grid('resolution',5*degree)
%
% Options
%  points     - number of points to be generated
%  resolution - resolution of the grid
%  hemisphere - 'lower', 'uper', 'complete', 'sphere', 'identified'
%  minRho     - starting rho angle (default 0)
%  maxRho     - maximum rho angle (default 2*pi)
%  minTheta   - starting theta angle (default 0)
%  maxTheta   - maximum theta angle (default pi)
%
% Flags
%  antipodal  - include <VectorsAxes.html antipodal symmetry>
%  restrict2MinMax - restrict margins to min / max
%  no_center  - ommit point at center
%
% See also
% regularS2Grid plotS2Grid


%  ind = rhoInside(rho,minrho,maxrho) & theta >= mintheta;
%  theta = theta(ind);
%  rho = rho(ind);
%
%  if isnumeric(maxtheta)
%    ind = theta <= maxtheta;
%  else
%    ind = theta <= maxtheta(rho);
%  end
%  theta = theta(ind);
%  rho = rho(ind);

res = get_option(varargin,'resolution',2.5*degree);

n = round(log(1/res)/log(2));

polar = HealpixGenerateSampling(2^n,1);


S2G = vector3d.byPolar(polar(:,1),polar(:,2));


return

% extract options
bounds = getPolarRange(varargin{:});

% get number of points
if check_option(varargin,'points') % calculate resolution
  ntheta = N2ntheta(fix(get_option(varargin,'points')),...
    bounds.VR{2},bounds.VR{4}-bounds.VR{3});%Check this
  res =  (bounds.VR{2}-bounds.VR{1}) / ntheta;
else
  res = get_option(varargin,'resolution',2.5*degree);
  res =  2* bounds.VR{2} / round(2 * bounds.VR{2} / res);
  ntheta = fix(round(2 * (bounds.VR{2}-bounds.VR{1}) / res + ...
    check_option(varargin,'no_center') )/2);
end

% define polar angle
if check_option(varargin,'no_center')
  theta =  (0.5:ntheta-0.5)*res;
else
  theta = (0:ntheta)*res;
end
theta = bounds.VR{1} + theta;

% define azimuth angles
identified = check_option(varargin,'antipodal');

rhGrid = repmat(S1Grid([],bounds.FR{3},bounds.FR{4} + pi,'periodic'),...
  1,length(theta));
for j = 1:length(theta)

  th = theta(j);
  if isappr(th,pi/2) && isappr(bounds.drho,2*pi) && identified
    rhGrid(j).max = bounds.FR{3} + pi;
    rhGrid(j).points = bounds.VR{3} + res*(0.5*mod(j,2)+(0:2*ntheta-1));
  else
    steps = max(round(sin(th) * bounds.drho / bounds.dtheta * ntheta),1);
    rhGrid(j).points = bounds.VR{3} + (0:steps-1 )* bounds.drho /steps + ...
      mod(j,2) * bounds.drho/steps/2;
  end
end

theta = S1Grid(theta,bounds.FR{1},bounds.FR{2});

if identified, opt = {'antipodal'}; else, opt = {}; end
S2G = S2Grid(theta,rhGrid,opt{:});
S2G = S2G.setOption('resolution',res);

% restrict to spherical region if specified
sR = getClass(varargin,'sphericalRegion');
if ~isempty(sR), S2G = S2G.subGrid(sR.checkInside(S2G,'noAntipodal')); end

end

% ---------------------------------------------------------
function ntheta = N2ntheta(N,maxtheta,maxrho)
ntheta = 1;
while calcAnz(ntheta,0,maxtheta,maxrho) < N
  ntheta = ntheta + 1;
end
if (calcAnz(ntheta,0,maxtheta,maxrho) - N) > (N-calcAnz(ntheta-1,0,maxtheta,maxrho))
  ntheta = ntheta-1;
end

end

function c = calcAnz(N,tmin,dt,dr)
c = sum(round(sin(tmin+dt/N*(1:N)) * dr/dt * N));
end
