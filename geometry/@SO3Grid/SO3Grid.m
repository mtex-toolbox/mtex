function G = SO3Grid(points,CS,SS,varargin)
% constructor
%
%% Syntax
%  S3G = SO3Grid(nodes,CS,SS)
%  S3G = SO3Grid(points,CS,SS)
%  S3G = SO3Grid(resolution,CS,SS)
%
%% Input
%  points     - number of nodes 
%  nodes      - @quaternion 
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

if isa(points,'quaternion')    % SO3rid defined by a set quaternions
	
	points = points  ./ norm(points);
	G.Grid = points;
  if numel(points) < 2
    G.resolution = 2*pi;
  elseif check_option(varargin,'resolution')
    G.resolution = get_option(varargin,'resolution');
  else
    %G.resolution = min(2*acos(dot_outer(CS,SS,points(1),points(2:end))))
    G.resolution = quat2res(points,CS,SS);
  end 
	
elseif maxangle < rotangle_max_z(CS)/4
  
  if points > 1
    res = maxangle / points^(1/3);
  else
    res = points;
  end
  
  rot_angle = res/2:res:maxangle;

  q = quaternion();
  for i = 1:length(rot_angle)
    dres = acos(max((cos(res/2)-cos(rot_angle(i)/2)^2)/...
      (sin(rot_angle(i)/2)^2),-1));
    rotax = S2Grid('equispaced','resolution',dres);
    q = [q,axis2quat(vector3d(rotax),rot_angle(i))];
  end
  
  G.resolution = res;  
  ind = fundamental_region(q,symmetry(),SS);  
  G.Grid = q(~ind);
  
elseif isa(points,'double') && points > 0  % discretise euler space

  % special case: cubic symmetry
  if strcmp(Laue(CS),'m-3') && points > 1 
    points = points*3;
  elseif strcmp(Laue(CS),'m-3m') && points > 1
    points = points*3/2;
  end
  
  [maxalpha,maxbeta,maxgamma] = symmetry2Euler(CS,SS,'SO3Grid');
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

  % arrange alpha, beta, gamma
  gamma  = dgamma+repmat(gamma.',1,GridLength(G.alphabeta));
	alpha = repmat(reshape(alpha,1,[]),ap2,1);
	beta  = repmat(reshape(beta,1,[]),ap2,1);
 
  G.gamma = S1Grid(gamma,-maxgamma+dgamma(1,:),...
    maxgamma+dgamma(1,:),'periodic','matrix');
	  
  Grid = euler2quat(alpha,beta,gamma);
	Grid = reshape(Grid,[],1);
	
	G.resolution = 2 * maxgamma / ap2;
	
  % eliminiate 3 fold symmetry axis of cubic symmetries
  ind = fundamental_region(Grid,CS,symmetry());

  if nnz(ind) ~= 0
    % eliminate those rotations
    Grid(ind) = [];
    
    % eliminate from index set
    G.gamma = subGrid(G.gamma,~ind);
    G.alphabeta  = subGrid(G.alphabeta,GridLength(G.gamma)>0);
    G.gamma(GridLength(G.gamma)==0) = [];
    
  end
  
  G.options = {'indexed'};
	G.Grid  = Grid;
    
end

superiorto('quaternion');
G = class(G,'SO3Grid');

if check_option(G,'indexed') && check_option(varargin,'MAX_ANGLE')
  G = subGrid(G,idquaternion,maxangle);
end

%--------------------------------------------------------------------------
%function c = calcAnz(N,tmin,dt,dr)    
%c = 2 + sum(round(sin(tmin+dt/N*(0:N)) * dr/dt * N));

function s = no_center(res)

if mod(round(2*pi/res),2) == 0
  s = 'no_center';
else
  s = '';
end

function res = quat2res(quat,CS,SS)

ml = min(numel(quat),500);
ind1 = randsample(1:numel(quat),ml);
ind2 = randsample(1:numel(quat),ml);
d = 2*acos(dot_outer(CS,SS,quat(ind1),quat(ind2)));
d(d<0.005) = pi;
res = quantile(min(d,[],2),min(0.9,sqrt(ml/numel(quat))));
