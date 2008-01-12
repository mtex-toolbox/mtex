function G = SO3Grid(points,CS,SS,varargin)
% constructor
%
%% Input
%  points     - nodes | number of nodes | resolution 
%  nodes      - @quaternion 
%  number     - int32
%  resolution - double
%  CS, SS     - @symmetry groups
%
%% Options
%  MAX_ANGLE  - only up to maximum rotational angle
%

if (nargout == 0) && (nargin == 0)
	disp('constructs a grid on SS\SO(3)/CS');
	disp('Arguments: points, CS, SS');
	return;
end

if nargin <= 0, points = 0; end
if nargin <= 1, CS = symmetry; end
if nargin <= 2, SS = symmetry; end
maxangle = get_option(varargin,'MAX_ANGLE',2*pi);

% standard settings
G.alphabeta = [];
G.gamma    = [];
G.resolution = 2*pi;
G.options = {};
G.CS      = CS;
G.SS      = SS;
G.Grid    = [];
G.subGrid = [];
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

  % special case: cubic symmetry
  if strcmp(Laue(CS),'m-3') && points > 1 
    points = points*3;
  elseif strcmp(Laue(CS),'m-3m') && points > 1
    points = points*3/2;
  end
  
  [maxalpha,maxbeta,maxgamma] = symmetry2Euler(CS,SS,'SO3Grid');
   maxbeta = min(maxbeta,maxangle);
  maxgamma = min(maxgamma/2,maxangle);
  
	if points >= 1  % number of points specified?
    
		% calculate number of subdivisions for the angles alpha,beta,gamma
    N = 1; res = maxbeta;
    G.alphabeta = S2Grid('equispaced','resolution',res,...
      'MAXTHETA',maxbeta,'MINRHO',0,'MAXRHO',maxalpha,...
      no_center(res));
    
    while round(2*N*maxgamma/maxbeta) * GridLength(G.alphabeta) < points 
      N = fix((N + 1) * ...
        (points / round(2*N*maxgamma/maxbeta) / GridLength(G.alphabeta)).^(0.2));
      res = maxbeta / N;
      G.alphabeta = S2Grid('equispaced','resolution',res,...
        'MAXTHETA',maxbeta,'MINRHO',0,'MAXRHO',maxalpha,...
        no_center(res));      
    end        
    ap2 = round(2 * maxgamma / res);

  else  % resolution specified
       
		G.alphabeta = S2Grid('equispaced','RESOLUTION',points,...
      'MAXTHETA',maxbeta,'MINRHO',0,'MAXRHO',maxalpha,...
      no_center(points));    
		ap2 = round(2*maxgamma/points);
  end

	[beta,alpha] = polar(G.alphabeta);
  
  % calculate gamma shift
  re = cos(beta).*cos(alpha) + cos(alpha);
  im = -(cos(beta)+1).*sin(alpha);
  dgamma = atan2(im,re);
  dgamma = repmat(reshape(dgamma,1,[]),ap2,1);
  gamma = -maxgamma + (0:ap2-1) * 2 * maxgamma / ap2;
  
  gamma  = dgamma+repmat(gamma.',1,GridLength(G.alphabeta));
	alpha = repmat(reshape(alpha,1,[]),ap2,1);
	beta  = repmat(reshape(beta,1,[]),ap2,1);
 
  G.gamma = S1Grid();
  for ig = 1:GridLength(G.alphabeta)
    G.gamma(ig) = S1Grid(gamma(:,ig),...
      -maxgamma+dgamma(1,ig),maxgamma+dgamma(1,ig),'periodic');
  end
	  
  Grid = euler2quat(alpha,beta,gamma);
	Grid = reshape(Grid,[],1);
	
	G.resolution = 2 * maxgamma / ap2;
	
	if strcmp(Laue(CS),'m-3m') || strcmp(Laue(CS),'m-3')
		
		c{1}.v = vector3d([1 1 1 1 -1 -1 -1 -1],[1 1 -1 -1 1 1 -1 -1],[1 -1 1 -1 1 -1 1 -1]);
		c{1}.h = sqrt(3)/3;
		
    if strcmp(Laue(CS),'m-3m')
      c{2}.v = vector3d([1 -1 0 0 0 0],[0 0 1 -1 0 0],[0 0 0 0 1 -1]);
      c{2}.h = sqrt(2)-1;
    end
		
    %if strcmp(Laue(SS),'mmm')
    % c{3}.v = vector3d([-1 0],[0 -1],[0 0]);
    % c{3}.h = 0;
    %end
    
		rodriguez = quat2rodriguez(Grid);  
    ind = zeros(numel(rodriguez),1);
    for i = 1:length(c)
      for j = 1:length(c{i}.v)
        p = dot(rodriguez,1/norm(c{i}.v(j)) * c{i}.v(j));
        ind = ind | (p>c{i}.h);
      end
    end
    
    Grid(ind) = [];
  else
    ind = [];
  end
  G.options = {'indexed'};
	G.Grid  = Grid;
  G.subGrid = ind;
end

superiorto('quaternion');
G = class(G,'SO3Grid');

if check_option(varargin,'MAX_ANGLE'), G = subGrid(G,idquaternion,maxangle);end

%--------------------------------------------------------------------------
%function c = calcAnz(N,tmin,dt,dr)    
%c = 2 + sum(round(sin(tmin+dt/N*(0:N)) * dr/dt * N));

function s = no_center(res)

if mod(round(2*pi/res),2) == 0
  s = 'no_center';
else
  s = '';
end
