function S2G = equispacedS2Grid(varargin)
% defines an equispaced spherical grid

% extract options

% rho range
minrhoGrid = 0;
maxrhoGrid = 2*pi;

minrho = get_option(varargin,'MINRHO',minrhoGrid);
maxrho = get_option(varargin,'MAXRHO',maxrhoGrid);
drho = maxrho - minrho;

% theta range
if check_option(varargin,'south')
  minthetaGrid = pi/2;
  maxthetaGrid = pi;
else
  minthetaGrid = 0;
  
  if check_option(varargin,{'antipodal','north'}) && ...
      (~check_option(varargin,'complete') ||check_option(varargin,'north'))
    maxthetaGrid = pi/2;
  else
    maxthetaGrid = pi;
  end
end

mintheta = max(get_option(varargin,'MINTHETA',minthetaGrid), ...
               minthetaGrid);

maxtheta = get_option(varargin,'MAXTHETA',maxthetaGrid);

if ~isnumeric(maxtheta)
  maxthetafun = @(rho) min(maxtheta(rho),maxthetaGrid);
  maxtheta = max(maxthetafun(linspace(minrho,maxrho,5)));
else
  maxtheta = min(maxtheta,maxthetaGrid);
end
dtheta = maxtheta - mintheta;

% srict theta and rho range
if check_option(varargin,'RESTRICT2MINMAX')
  minrhoGrid = minrho;
  maxrhoGrid = maxrho;
  minthetaGrid = mintheta;
  maxthetaGrid = maxtheta;
end


% equidistribution

if check_option(varargin,'points') % calculate resolution
  ntheta = N2ntheta(fix(get_option(varargin,'points')),maxtheta,maxrho);
  res =  maxtheta / ntheta;
else
  res = get_option(varargin,'RESOLUTION',2.5*degree);
  res =  2* maxtheta / round(2 * maxtheta / res);
  ntheta = fix(round(2 * maxtheta / res+ check_option(varargin,'NO_CENTER') )/2);
end


if check_option(varargin,'NO_CENTER')
  theta = mintheta + (0.5:ntheta-0.5)*res;
else
  theta = mintheta + (0:ntheta)*res;
end
G.theta = S1Grid(theta,minthetaGrid,maxthetaGrid);


identified = check_option(varargin,'antipodal');
for j = 1:length(theta)
  
  th = theta(j);
  if isappr(th,pi/2) && isappr(drho,2*pi) && identified
    
    G.rho(j) = S1Grid(minrho + G.res*(0.5*mod(j,2)+(0:2*ntheta-1))...
      ,minrhoGrid,minrhoGrid + pi,'PERIODIC');
    
  else
    steps = max(round(sin(th) * drho / dtheta * ntheta),1);
    rho = minrho + (0:steps-1 )* drho /steps + mod(j,2) * drho/steps/2;
    G.rho(j) = S1Grid(rho,minrhoGrid,maxrhoGrid,'PERIODIC');
  end
end

S2G = S2Grid(calcGrid(G.theta,G.rho),theta,rho,'resolution',res,varargin{:});


S2G = set_option(S2G,...
  extract_option(varargin,{'INDEXED','PLOT','north','south','antipodal','lower','upper'}));


end


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

