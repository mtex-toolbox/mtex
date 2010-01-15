function [G,varargout] = SO3Grid(points,CS,SS,varargin)
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
%  regular    - construct a regular grid
%  equispaced - construct a equispaced grid%
%  phi        - use phi
%  ZXZ, Bunge - Bunge (phi1 Phi phi2) convention
%  ZYZ, ABG   - Matthies (alpha beta gamma) convention
%  MAX_ANGLE  - only up to maximum rotational angle
%  CENTER     - with respect to this given center

if nargin <= 0, points = 0; end
if nargin <= 1, CS = symmetry; end
if nargin <= 2, SS = symmetry; end
maxangle = get_option(varargin,'MAX_ANGLE',2*pi);

argin_check(points,{'double','quaternion','char'});
argin_check(CS,'symmetry');
argin_check(SS,'symmetry');

% standard settings
G.alphabeta = [];
G.gamma    = [];
G.resolution = 2*pi;
G.options = {};
G.CS      = CS;
G.SS      = SS;
G.center  = [];
G.Grid    = quaternion;

%% SO3rid defined by a set quaternions
if isa(points,'quaternion')    
	
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

%% regular grid
elseif isa(points,'char') && any(strcmpi(points,{'plot','regular'}))

  % determine parameterisation
  if strcmpi(points,'plot') 
    sectype= 'sigma'; % default for plot
  elseif check_option(varargin,{'Bunge','ZXZ'})
    sectype= 'phi1';  % default for Bunge
  else
    sectype= 'alpha'; % default for regular
  end
      
  sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma'},sectype);
  
  [max_rho,max_theta,max_sec] = getFundamentalRegion(CS,SS,varargin{:});

  if any(strcmp(sectype,{'alpha','phi1'}))
    dummy = max_sec; max_sec = max_rho; max_rho = dummy;
  end

  % sections
  nsec = get_option(varargin,'SECTIONS',round(max_sec/degree/5));
  sec = linspace(0,max_sec,nsec+1); sec(end) = [];
  sec = get_option(varargin,sectype,sec,'double');
  nsec = length(sec);

  S2G = S2Grid(points,'MAXTHETA',max_theta,'MAXRHO',max_rho,'RESTRICT2MINMAX',varargin{:});

  % generate SO(3) plot grids
  [theta,rho] = polar(S2G);
  sec_angle = repmat(reshape(sec,[1,1,nsec]),[GridSize(S2G),1]);
  theta  = reshape(repmat(theta ,[1,1,nsec]),[GridSize(S2G),nsec]);
  rho = reshape(repmat(rho,[1,1,nsec]),[GridSize(S2G),nsec]);
  
  % set convention
  switch lower(sectype)
    case {'phi1','phi2'}
      convention = 'ZXZ';
    case {'alpha','gamma','sigma'}
      convention = 'ZYZ';
  end

  % set order   
  switch lower(sectype)
    case {'phi_1','alpha','phi1'}
      [sec_angle,theta,rho] = deal(sec_angle,theta,rho);      
    case {'phi_2','gamma','phi2'}
      [sec_angle,theta,rho] = deal(rho,theta,sec_angle);
    case 'sigma'
      [sec_angle,theta,rho] = deal(rho,theta,sec_angle-rho);
  end
  G.Grid = euler2quat(sec_angle,theta,rho,convention);
  
  % extra output
  if strcmpi(points,'plot')
    varargout{1} = S2G;
    varargout{2} = sec;
  else
    varargout{1} = G.alphabeta;
  end
  
  G.alphabeta = [sec_angle(:),theta(:),rho(:)];      
  G.options = {convention};
  G.resolution = getResolution(S2G);
  
%% local Grid
elseif maxangle < rotangle_max_z(CS)/4
  
  if points > 1
    res = maxangle / points^(1/3);
  else
    res = points;
  end
  
  rot_angle = res/2:res:maxangle;

  % construct complete grid
  q = quaternion();
  for i = 1:length(rot_angle)
    dres = acos(max((cos(res/2)-cos(rot_angle(i)/2)^2)/...
      (sin(rot_angle(i)/2)^2),-1));
    rotax = S2Grid('equispaced','resolution',dres);
    q = [q,axis2quat(vector3d(rotax),rot_angle(i))]; %#ok<AGROW>
  end
  
  G.resolution = res;  
  
  % restrict to fundamental region - specimen symetry only
  center = get_option(varargin,'center',idquaternion);
  sym_center = symmetriceQuat(CS,SS,center);
  [ignore,center] = selectMinbyRow(rotangle(sym_center),sym_center);
  
  for i = 1:length(center)
    cq = center(i) * q(:);
    ind = fundamental_region2(cq,center(i),CS,SS);
    G.Grid = [G.Grid;cq(ind)];
  end
  
%% equidistribution  
elseif isa(points,'double') && points > 0  % discretise euler space

  % special case: cubic symmetry
  if strcmp(Laue(CS),'m-3') && points > 1 
    points = points*3;
  elseif strcmp(Laue(CS),'m-3m') && points > 1
    points = points*3/2;
  end
  
  [maxalpha,maxbeta,maxgamma] = symmetry2Euler(CS,SS,'SO3Grid');
  if ~check_option(varargin,'center')
    maxgamma = min(maxgamma/2,maxangle);
  else
    maxgamma = maxgamma/2;
  end
  
  
  if points >= 1  % number of points specified?
    
    % calculate number of subdivisions for the angles alpha,beta,gamma
    N = 1; res = maxbeta;
    G.alphabeta = S2Grid('equispaced','resolution',res,...
                         'MAXTHETA',maxbeta,'MINRHO',0,'MAXRHO',maxalpha,...
                         no_center(res),'RESTRICT2MINMAX');
    
    while round(2*N*maxgamma/maxbeta) * GridLength(G.alphabeta) < points 
      N = fix((N + 1) * ...
              (points / round(2*N*maxgamma/maxbeta) / GridLength(G.alphabeta)).^(0.2));
      res = maxbeta / N;
      G.alphabeta = S2Grid('equispaced','resolution',res,...
                           'MAXTHETA',maxbeta,'MINRHO',0,'MAXRHO',maxalpha,...
                           no_center(res),'RESTRICT2MINMAX');      
    end        
    ap2 = round(2 * maxgamma / res);

  else  % resolution specified
       
    G.alphabeta = S2Grid('equispaced','RESOLUTION',points,...
                         'MAXTHETA',maxbeta,'MINRHO',0,'MAXRHO',maxalpha,...
                         no_center(points),'RESTRICT2MINMAX');    
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
  center = get_option(varargin,'center',idquaternion);
  G = subGrid(G,center,maxangle);
end


function s = no_center(res)

if mod(round(2*pi/res),2) == 0
  s = 'no_center';
else
  s = '';
end

function res = quat2res(quat,CS,SS)

ml = min(numel(quat),500);
ind1 = discretesample(numel(quat),ml);
ind2 = discretesample(numel(quat),ml);
d = 2*acos(dot_outer(CS,SS,quat(ind1),quat(ind2)));
d(d<0.005) = pi;
res = quantile(min(d,[],2),min(0.9,sqrt(ml/numel(quat))));
