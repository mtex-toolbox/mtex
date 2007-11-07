function G = S2Grid(varargin)
% constructor
%% Input
%  nodes           - @vector3d |
%  number of nodes - int32 |
%  [theta,rho]     - [int32,int32]  (optional)       
%
%% Options
%  RESOLUTION -          
%
%% Flags
%  HEMISPHERE - 
%  PLOT       -
%  MAXRHO     -
%  MAXTHETA   -
%  NO_CENTER  -
     
maxtheta = get_option(varargin,'MAXTHETA',pi/2);
maxrho = get_option(varargin,'MAXRHO',2*pi);

if nargin == 0
	G.res = 2*pi;
	G.theta = [];
	G.rho = [];
	G.Grid = vector3d;
	G.options = {};
  
elseif isa(varargin{1},'S2Grid')	
	G = varargin{1};	
  
elseif isa(varargin{1},'vector3d')	
  
	G.res = get_option(varargin,'RESOLUTION',vec2res(varargin{1}));
	G.theta =  [];
	G.rho = [];
	G.Grid = varargin{1};
	G.options = {};
	
% -------------------------- indexed grid ----------------------------
else

  % regular
  if isa(varargin{1},'double') && length(varargin{1}) == 2
    
    points = varargin{1};	
		G.res = min(maxtheta/points(2),maxrho/points(1));
		G.theta = S1Grid(linspace(0,maxtheta,points(2)),0,maxtheta);
		steps = maxrho / points(1);
    if check_option(varargin,'PLOT'),
      G.rho = repmat(...
        S1Grid([steps*(0:points(1)-1),0],0,maxrho,'PERIODIC'),...
        1,points(2));
    else
      G.rho = repmat(...
        S1Grid(steps*(0:points(1)-1),0,maxrho,'PERIODIC'),...
        1,points(2));
    end
    
  elseif check_option(varargin,{'theta','rho'})
    
    theta = get_option(varargin,'theta',[]);
    rho = get_option(varargin,'rho',[]);
    if check_option(varargin,'PLOT'), rho = [rho,rho(0)];end
    
    G.res = min(abs(theta(1)-theta(2)),abs(rho(1)-rho(2)));
    G.theta = S1Grid(theta,0,max(theta));
    G.rho = repmat(...
      S1Grid(rho,0,2*pi,'PERIODIC'),...
      1,length(theta));
    
  % plot grid
  elseif check_option(varargin,'PLOT')
    
    res = pi/2/round(pi/2/get_option(varargin,'RESOLUTION',2.5*degree));
    ntheta = ceil(maxtheta/res);
    nrho = ceil(maxrho/res);
    
    G.res = res;
    G.theta = S1Grid(res*(0:ntheta),0,maxtheta);
    G.rho = repmat(...
			S1Grid(res*(0:nrho),0,maxrho,'PERIODIC'),...
      1,ntheta+1);
    
  % equidistribution
  else
        
    if isa(varargin{1},'double') 			% calculate resolution
      ntheta = N2ntheta(varargin{1},maxtheta,maxrho);
    else
      ntheta = round(maxtheta / get_option(varargin,'RESOLUTION',2.5*degree));
    end
		
		G.res = maxtheta/ntheta;
    if check_option(varargin,'NO_CENTER')
      theta = (0.5:ntheta-0.5)*maxtheta/ntheta;
    else
      theta = linspace(0,maxtheta,ntheta+1);
    end
		G.theta = S1Grid(theta,0,maxtheta);
    
		for j = 1:length(theta) 
        
			th = theta(j);
			if j == ntheta+1 && maxrho == 2*pi && maxtheta == pi/2
				G.rho(ntheta+1) = S1Grid(G.res*(0.5*mod(j,2)+(0:2*ntheta-1))...
					,0,pi,'PERIODIC');
			else
				steps = max(round(sin(th) * maxrho/maxtheta * ntheta),1);
				rho = (0:steps-1)*maxrho/steps + mod(j,2)*maxrho/steps/2;
				G.rho(j) = S1Grid(rho,0,maxrho,'PERIODIC'); %#ok<AGROW>
			end	
		end
  end
  
  G.Grid = calcGrid(G.theta,G.rho);
	G.options = {'INDEXED'};
end
  
G.options = set_option(G.options,extract_option(varargin,{'INDEXED','HEMISPHERE','PLOT'}));
G = class(G,'S2Grid');
    

function res = vec2res(vec)
ind = randperm(min(100,numel(vec)));
d = acos(dot_outer(vec(ind),vec(:)));
d(d<0.005) = pi/2;
res = quantile(min(d,[],2),0.25);

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
