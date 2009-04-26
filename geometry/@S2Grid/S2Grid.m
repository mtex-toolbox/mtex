function G = S2Grid(varargin)
% constructor
%
%% Syntax
%  S2Grid(nodes)
%  S2Grid('regular',<options>)
%  S2Grid('equispaced',<options>)
%
%% Input
%  nodes           - @vector3d 
%
%% Options
%  POINTS     - [nrho,ntheta] number of points to be generated
%  RESOLUTION - resolution of a equispaced grid
%  HEMISPHERE - { NORTH | SOUTH | BOTH | IDENTIFIED }
%  THETA      - theta angle
%  RHO        - rho angle
%
%% Flags  
%  REGULAR    - generate a regular grid
%  EQUISPACED - generate equidistribution
%  NORTH      - northern hemisphere
%  SOUTH      - southern hemisphere
%  REDUCED    - 
%  PLOT       - generate plotting grid
%  MINRHO     - starting rho angle (default 0)
%  MAXRHO     - maximum rho angle (default 2*pi)
%  MINTHETA   - starting theta angle (default 0)
%  MAXTHETA   - maximum theta angle (default pi)
%  NO_CENTER  - ommit point at center
%
%% Examples
%
%  S2Grid('regular','points',[72 19])
%  S2Grid('regular','resolution',[5*degree 2.5*dgree])
%  S2Grid('equispaced','resolution',5*degree,'maxrho',pi)
%
%% See also
%

%% extract options

if check_option(varargin,'north')  
  mintheta = 0; 
  if check_option(varargin,'south')
    maxtheta = pi;
  else
    maxtheta = pi/2;
  end
elseif check_option(varargin,'south')
  mintheta = pi/2; maxtheta = pi;
elseif check_option(varargin,'reduced')
  mintheta = 0; maxtheta = pi/2;
else  
  mintheta = 0; maxtheta = pi;
end

minrho = get_option(varargin,'MINRHO',0);
maxrho = get_option(varargin,'MAXRHO',2*pi);
drho = maxrho - minrho;
if ~isappr(drho,2*pi) && check_option(varargin,'rotate')
  rotate = get_option(varargin,'rotate',0);
  minrho = minrho -rotate;
  maxrho = maxrho -rotate;
end

mintheta = max(get_option(varargin,'MINTHETA',0),mintheta);
maxtheta_opt = get_option(varargin,'MAXTHETA',pi);
if ~isnumeric(maxtheta_opt)
  maxthetafun = @(rho) min(maxtheta_opt(rho),maxtheta);
  maxtheta = max(maxthetafun(linspace(minrho,maxrho,5)));
else
  maxtheta = min(maxtheta_opt,maxtheta);
end
dtheta = maxtheta - mintheta;


%% 
if nargin == 0 || ... % empty grid
    (check_option(varargin,{'theta','rho'}) && isempty(get_option(varargin,'theta')))
  G.res = 2*pi;
  G.theta = S1Grid([],mintheta,maxtheta);
  G.rho = S1Grid([],minrho,maxrho);
  G.Grid = vector3d;
  G.options = {};
  
elseif isa(varargin{1},'S2Grid') % copy constructor
  
	G = varargin{1};	
  
elseif isa(varargin{1},'vector3d')	% grid from vector3d
  
	G.res = get_option(varargin,'RESOLUTION',vec2res(varargin{1}));
  if exist('maxthetafun','var')
    G.theta = maxthetafun;
  else
    G.theta =  S1Grid([],mintheta,maxtheta);
  end
	G.rho = S1Grid([],minrho,maxrho);
	G.Grid = varargin{1};
  [theta,rho] = vec2sph(G.Grid);
    
  G.Grid = G.Grid(theta<=maxtheta+1e-06 & inside(rho,minrho,maxrho));
	G.options = {};
	
elseif check_option(varargin,'plot') && exist('maxthetafun','var')
  
  res = get_option(varargin,'resolution',2.5*degree);
  points(1) = ceil(drho / res);
  points(2) = ceil(dtheta / res + 1);

  G.res = min(dtheta/(points(2)-1),drho/points(1));
  G.theta = maxthetafun;
  G.rho = S1Grid([],minrho,maxrho);
  
  rho = linspace(minrho,maxrho,points(1));
  theta = linspace(mintheta,maxtheta,points(2));
  %theta = [theta,theta(end)];
  
  [rho,theta] = meshgrid(rho,theta);
  theta = theta * diag(maxthetafun(rho(1,:))./maxtheta);
  
  G.Grid = sph2vec(theta,rho);
  G.options = {};
  
  
% -------------------------- indexed grid ----------------------------
else

  % theta and rho are given
  if check_option(varargin,{'theta','rho'})
    
    theta = get_option(varargin,'theta',[]);
    rho = get_option(varargin,'rho',[]);
    if check_option(varargin,'PLOT'), rho = [rho,rho(0)];end
    
    if numel(theta)<2
      G.res = 2*pi;
    else
      G.res = min(abs(theta(1)-theta(2)),abs(rho(1)-rho(2)));
    end
    G.theta = S1Grid(theta,0,maxtheta);%max(theta)
    G.rho = repmat(...
      S1Grid(rho,0,2*pi,'PERIODIC'),...
      1,length(theta));
  
  % regular
  elseif check_option(varargin,{'regular','plot'})
    
    if check_option(varargin,'points')
      points = get_option(varargin,'points');
      if length(points) == 1
        res = sqrt(drho * dtheta/points);
        res = dtheta/round(dtheta/res);
        points = round([drho/res dtheta/res]);
      end
    else
      points = get_option(varargin,'resolution',...
        5*degree ./ (1+check_option(varargin,'plot')));
      if length(points) == 1, points = [points points];end      
      points(1) = ceil(drho / points(1));
      points(2) = ceil(dtheta / points(2) + 1);
    end
    
    G.res = min(dtheta/(points(2)-1),drho/points(1));
    G.theta = S1Grid(linspace(mintheta,maxtheta,points(2)),mintheta,maxtheta);
      
		steps = (maxrho-minrho) / points(1);
    if check_option(varargin,'PLOT'),
      G.rho = repmat(...
        S1Grid(minrho + steps*(0:points(1)),minrho,maxrho),1,points(2));
    else
      G.rho = repmat(...
        S1Grid(minrho + steps*(0:points(1)-1),minrho,maxrho,...
        'PERIODIC'),1,points(2));
    end
       
  % equidistribution
  elseif check_option(varargin,'equispaced')
       
    if check_option(varargin,'points') % calculate resolution
      ntheta = N2ntheta(get_option(varargin,'points'),maxtheta,maxrho);
      res =  maxtheta / ntheta;
    else
      res = get_option(varargin,'RESOLUTION',2.5*degree);
      res =  2* maxtheta / round(2 * maxtheta / res);
      ntheta = fix(round(2 * maxtheta / res+ check_option(varargin,'NO_CENTER') )/2);
    end
        
    G.res = res;
    if check_option(varargin,'NO_CENTER')
      theta = mintheta + (0.5:ntheta-0.5)*res;
    else
      theta = mintheta + (0:ntheta)*res;
    end
    G.theta = S1Grid(theta,mintheta,maxtheta);
                
    identified = check_option(varargin,'reduced');
    for j = 1:length(theta)
        
      th = theta(j);
      if isappr(th,pi/2) && isappr(drho,2*pi) && identified
        
        G.rho(j) = S1Grid(minrho + G.res*(0.5*mod(j,2)+(0:2*ntheta-1))...
          ,minrho,minrho + pi,'PERIODIC');
      
      else
        steps = max(round(sin(th) * drho / dtheta * ntheta),1);
        rho = minrho + (0:steps-1 )* drho /steps + mod(j,2) * drho/steps/2;
        G.rho(j) = S1Grid(rho,minrho,maxrho,'PERIODIC'); 
      end
    end
  else
    error('no grid type specified');
  end  
  
  G.Grid = calcGrid(G.theta,G.rho);
  G.options = {'INDEXED'};
    
end
  
G.options = set_option(G.options,...
  extract_option(varargin,{'INDEXED','PLOT','north','south','reduced'}));

G = class(G,'S2Grid');
    

function res = vec2res(vec)
if numel(vec) < 10, res = 2*pi;return; end
ind = discretesample(numel(vec),min(50,numel(vec)));
d = acos(dot_outer(vec(ind),vec(:)));
d(d<0.005) = pi/2;
%res = quantile(min(d,[],2),0.25);
res = quantile(min(d,[],2),0.5);



function ntheta = N2ntheta(N,maxtheta,maxrho)
ntheta = 1;
while calcAnz(ntheta,0,maxtheta,maxrho) < N
  ntheta = ntheta + 1;
end
if (calcAnz(ntheta,0,maxtheta,maxrho) - N) > (N-calcAnz(ntheta-1,0,maxtheta,maxrho))
  ntheta = ntheta-1;
end

function c = calcAnz(N,tmin,dt,dr)
c = sum(round(sin(tmin+dt/N*(1:N)) * dr/dt * N));
