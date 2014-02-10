function S2G = equispacedS2Grid(varargin)
% defines an equispaced spherical grid
%
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
  

% extract options
bounds = getPolarRange(varargin{:});

% get number of points
if check_option(varargin,'points') % calculate resolution
  ntheta = N2ntheta(fix(get_option(varargin,'points')),...
    bounds.VR{2},bounds.VR{4}-bounds.VR{3});%Check this 
  res =  bounds.VR{2} / ntheta;
else
  res = get_option(varargin,'resolution',2.5*degree);
  res =  2* bounds.VR{2} / round(2 * bounds.VR{2} / res);
  ntheta = fix(round(2 * bounds.VR{2} / res + ...
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

for j = 1:length(theta)
  
  th = theta(j);
  if isappr(th,pi/2) && isappr(bounds.drho,2*pi) && identified
    
    rh = bounds.VR{3} + res*(0.5*mod(j,2)+(0:2*ntheta-1));
    rho(j) = S1Grid(rh,bounds.FR{3},bounds.FR{3} + pi,'periodic'); %#ok<AGROW>
    
  else
    
    steps = max(round(sin(th) * bounds.drho / bounds.dtheta * ntheta),1);
    rh = bounds.VR{3} + (0:steps-1 )* bounds.drho /steps + ...
      mod(j,2) * bounds.drho/steps/2;
    rho(j) = S1Grid(rh,bounds.FR{3},bounds.FR{4},'periodic'); %#ok<AGROW>
  end
end

theta = S1Grid(theta,bounds.FR{1},bounds.FR{2});

S2G = S2Grid(theta,rho);
S2G = S2G.setOption('resolution',res);

%S2G = set_option(S2G,...
%  extract_option(varargin,{'INDEXED','PLOT','north','south','antipodal','lower','upper'}));


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

