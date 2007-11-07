function G = SO3Grid(points,CS,SS,varargin)
% constructor
%% Input
%  points     - nodes | number of nodes | resolution 
%  nodes      - @quaternion 
%  number     - int32
%  resolution - double
%  CS, SS     - @symmetry groups
%% Options
%  CALC_DISTMATRIX - calculate distance matrix for all nodes 
%  MAX_ANGLE       - only up to maximum rotational angle

if (nargout == 0) && (nargin == 0)
	disp('constructs a grid on SS\SO(3)/CS');
	disp('Arguments: points, CS, SS');
	return;
end

if nargin <= 0, points = 0; end
if nargin <= 1, CS = symmetry; end
if nargin <= 2, SS = symmetry; end
diameter = get_option(varargin,'MAX_ANGLE',2*pi);

% standard settings
G.alphabeta = [];
G.gamma    = [];
G.resolution = 2*pi;
G.options = {};
G.CS      = CS;
G.SS      = SS;
G.Grid    = [];
G.dMatrix = [];

if isa(points,'quaternion')    % SO3rid defined by a set quaternions
	
	points = points  ./ norm(points);
	G.Grid = points;
  if numel(points) < 2
    G.resolution = 2*pi;
  else
	  G.resolution = min(2*acos(dot_outer(CS,SS,points(1),points(2:end))));
  end 
	   
elseif isa(points,'double') && points > 0  % discretise euler space

  if strcmp(Laue(CS),'m-3')
    if points > 1, points = points*12;end
    maxalpha = 2*pi;maxgamma = 2*pi;maxbeta = pi;
  elseif strcmp(Laue(CS),'m-3m')
    if points > 1, points = points*24;end
    maxalpha = 2*pi;maxgamma = 2*pi;maxbeta = pi;
  else
    
    [maxalpha,maxbeta,maxgamma] = symmetry2Euler(CS,SS);
    
%  maxalpha = maxrho(SS,'ALPHA');
%  maxbeta = min(diameter,maxtheta(CS));
%  maxgamma = maxrho(CS);
  end
        
	if points >= 1  % number of points specified?
		% calculate number of subdivisions for the angles alpha,beta,gamma
		N = 1; ap2=1;
		while round(N*maxgamma/maxbeta)*calcAnz(N,0,maxbeta,maxalpha) < points
			N = N + 1;
			ap2 = round(N * maxgamma/maxbeta);
		end
		G.alphabeta = S2Grid(calcAnz(N,0,maxbeta,maxalpha),'MAXTHETA',maxbeta,'MAXRHO',maxalpha);
  else  % resolution specified
		G.alphabeta = S2Grid('RESOLUTION',points,'MAXTHETA',maxbeta,'MAXRHO',maxalpha);
		ap2 = round(maxgamma/points);
	end
	
	[beta,alpha] = polar(G.alphabeta);
	alpha = repmat(reshape(alpha,1,[]),ap2,1);
	beta  = repmat(reshape(beta,1,[]),ap2,1);
  
	gamma = (0:ap2-1) * maxgamma / ap2;
	G.gamma = S1Grid(gamma,0,maxgamma);
	gamma  = repmat(gamma.',1,GridLength(G.alphabeta));
	G.gamma = repmat(G.gamma,1,GridLength(G.alphabeta));
	
	Grid = euler2quat(alpha,beta,gamma);
	Grid = reshape(Grid,[],1);
	
	G.resolution = maxgamma / ap2;
	
	if strcmp(Laue(CS),'m-3m') || strcmp(Laue(CS),'m-3')
		
		c{1}.v = vector3d([1 1 1 1 -1 -1 -1 -1],[1 1 -1 -1 1 1 -1 -1],[1 -1 1 -1 1 -1 1 -1]);
		c{1}.h = sqrt(3)/3;
		
		if strcmp(Laue(CS),'m-3m')
			c{2}.v = vector3d([1 -1 0 0 0 0],[0 0 1 -1 0 0],[0 0 0 0 1 -1]);
			c{2}.h = sqrt(2)-1;
		end
		
		rodriguez = quat2rodriguez(Grid);

		for i = 1:length(c)
			for j = 1:length(c{i}.v)
				p = dot(rodriguez,1/norm(c{i}.v(j)) * c{i}.v(j));
				ind = find(p>c{i}.h);
				rodriguez(ind) = [];
				Grid(ind) = [];
			end
		end
	else
		G.options = {'indexed'};
  end
	G.Grid  = Grid;
end

superiorto('quaternion');
G = class(G,'SO3Grid');

if check_option(varargin,'MAX_ANGLE'), G = subGrid(G,idquaternion,diameter);end
if check_option(varargin,'CALC_DISTMATRIX'), G.dMatrix = distMatrix(G,G,2*G.resolution);end

%--------------------------------------------------------------------------
function c = calcAnz(N,tmin,dt,dr)    
c = sum(round(sin(tmin+dt/N*(1:N)) * dr/dt * N));
