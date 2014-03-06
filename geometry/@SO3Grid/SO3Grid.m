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
G.CS = CS;
G.SS = SS;
G.alphabeta = [];
G.gamma    = [];
G.resolution = 2*pi;
G.options = {};
G.center  = [];
Grid = orientation(rotation,CS,SS);

%% SO3rid defined by a set quaternions
if isa(points,'quaternion')
  
  points = points  ./ norm(points);
  Grid = points;
  
  if numel(points) < 2
    G.resolution = 2*pi;
  elseif check_option(varargin,'resolution')
    G.resolution = get_option(varargin,'resolution');
  else
    G.resolution = ori2res(orientation(Grid,CS,SS));
  end
  
elseif isa(points,'char') && any(strcmpi(points,{'random'}))
  
  N = fix(get_option(varargin,'points',1000));
  Grid = randq(N);
  G.resolution = ori2res(Grid);
  
  %% regular grid
elseif isa(points,'char') && any(strcmpi(points,{'plot','regular'}))
  
  % default sectioning for plot grids
  sectype = 'unknown';
  if strcmpi(points,'plot'), sectype= 'phi2'; end
  
  % check whether sectioning type is given explictely
  sectype = get_flag(varargin,{'alpha','phi1','gamma','phi2','sigma','axisangle','omega','omega2','psi'},sectype);
  
  % if sectioning is given, it defines the Euler angle convention
  switch lower(sectype)
    
    case {'phi1','phi2'}
      
      convention = 'Bunge';
      
    case {'alpha','gamma','sigma','omega'}
      
      convention = 'Matthies';
      
    case 'omega2'
      
      convention = 'Canova';
      
    case 'psi'
      
      convention = 'Kocks';
      
    case 'axisangle'
      
    otherwise % determine convention
      
      % determine Euler angle parameterisation
      convention = EulerAngleConvention(varargin{:});
      
      switch convention
        
        case {'Matthies','nfft','ZYZ','ABG'}
          
          sectype = 'alpha';
          
        case 'Roe'
          
          sectype = 'Psi';
          
        case {'Bunge','ZXZ'}
          
          sectype = 'phi1';
          
        case {'Kocks'}
          
          sectype = 'Psi';
          
        case {'Canova'}
          
          sectype = 'omega';
          
      end
  end
  
  % get bounds
  [max_rho,max_theta,max_sec] = getFundamentalRegion(CS,SS,varargin{:});
  
  % make the sectioning variable to be the last one
  if any(strcmpi(sectype,{'alpha','phi1','Psi'}))
    dummy = max_sec; max_sec = max_rho; max_rho = dummy;
  elseif strcmpi(sectype,'omega')
    max_sec = 2*pi;
  end
  
  % sections
  nsec = get_option(varargin,'SECTIONS',...
    round(max_sec/get_option(varargin,'resolution',5*degree)));
  sec = linspace(0,max_sec,nsec+1); sec(end) = [];
  sec = get_option(varargin,sectype,sec,'double');
  nsec = length(sec);
  
  % special case axis/angle
  if strcmpi(sectype,'axisangle')
    
    S2G = S2Grid('plot','upper',varargin{:});
    
    for i=1:nsec
      Grid(:,:,i) = axis2quat(S2G,sec(i));
    end
    
    G.alphabeta = Euler(Grid,'ABG');
    G.options = {'ZYZ'};
    G.resolution = get(S2G,'resolution');
    
  else % parameterisation by Euler angles
    
    % no sectioning angles
    S2G = S2Grid(points,'MAXTHETA',max_theta,'MAXRHO',max_rho,'RESTRICT2MINMAX',varargin{:});
    [theta,rho] = polar(S2G);
    
    % build size(S2G) x nsec matrix of Euler angles
    sec_angle = repmat(reshape(sec,[1,1,nsec]),[size(S2G),1]);
    theta  = reshape(repmat(theta ,[1,1,nsec]),[size(S2G),nsec]);
    rho = reshape(repmat(rho,[1,1,nsec]),[size(S2G),nsec]);
    
    % set order
    switch lower(sectype)
      case {'phi_1','alpha','phi1'}
        [sec_angle,theta,rho] = deal(sec_angle,theta,rho);
      case {'phi_2','gamma','phi2'}
        [sec_angle,theta,rho] = deal(rho,theta,sec_angle);
      case {'sigma','omega'}
        [sec_angle,theta,rho] = deal(rho,theta,sec_angle-rho);
    end
    
    % define grid
    Grid = euler2quat(sec_angle,theta,rho,convention);
    
    if strcmpi(sectype,'omega')
      hpos = find_type(varargin,'Miller');
      if hpos > 0, h = varargin{hpos}(1);
      else h = Miller(0,0,1,CS); end      
      [alpha,beta] = polar(h);
      Grid = Grid.*inverse(euler2quat(beta,alpha,0,convention));
    end
    
    % store gridding, @TODO: check when its required 
    G.alphabeta = [sec_angle(:),theta(:),rho(:)];
    G.options = {convention};
    G.resolution = get(S2G,'resolution');
  end
  
  % extra output
  if strcmpi(points,'plot')
    varargout{1} = S2G;
    varargout{2} = sec;
  else
    varargout{1} = G.alphabeta;
  end
  
  %% local Grid
elseif maxangle < rotangle_max_z(CS)/4
  
  if points > 1
    res = maxangle/(points/4)^(1/3);
    %  res = maxangle / points^(1/3)
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
  
  % restrict to fundamental region - specimen symmetry only
  center = get_option(varargin,'center',idquaternion);
  sym_center = quaternion(symmetrise(center,CS,SS));
  [ignore,center] = selectMinbyColumn(angle(sym_center),sym_center); %#ok<ASGLU>
  
  for i = 1:length(center)
    cq = center(i) .* q(:);
    if numel(SS) > 1
      ind = fundamental_region2(cq,center(i),CS,SS);
      cq = cq(ind);
    end
    Grid = [Grid;orientation(cq,CS,SS)]; %#ok<AGROW>
  end
  
  %% equidistribution
elseif isa(points,'double') && points > 0  % discretise euler space
  
  [maxalpha,maxbeta,maxgamma] = symmetry2Euler(CS,SS,'SO3Grid');
  
  maxgamma = maxgamma/2;
  
  if ~check_option(varargin,'center')
    maxgamma = min(maxgamma,maxangle);
  end
  
  if points >= 1  % number of points specified?
    switch Laue(CS)  % special case: cubic symmetry
      case 'm-3'
        points = 3*points;
      case 'm-3m'
        points = 2*points;
    end
    % calculate number of subdivisions for the angles alpha,beta,gamma
    points = 2/(points/( maxbeta*maxgamma))^(1/3);
    
    if  maxangle < pi*2 && maxangle < maxbeta
      points = points*maxangle; % bug: does not work properly for all syms
    end
    
  end
  
  G.alphabeta = S2Grid('equispaced','RESOLUTION',points,...
    'MAXTHETA',maxbeta,'MINRHO',0,'MAXRHO',maxalpha,...
    no_center(points),'RESTRICT2MINMAX');
  ap2 = round(2*maxgamma/points);
  
  [beta,alpha] = polar(G.alphabeta);
  
  % calculate gamma shift
  re = cos(beta).*cos(alpha) + cos(alpha);
  im = -(cos(beta)+1).*sin(alpha);
  dgamma = atan2(im,re);
  dgamma = repmat(reshape(dgamma,1,[]),ap2,1);
  gamma = -maxgamma + (0:ap2-1) * 2 * maxgamma / ap2;
  
  % arrange alpha, beta, gamma
  gamma  = dgamma+repmat(gamma.',1,numel(G.alphabeta));
  alpha = repmat(reshape(alpha,1,[]),ap2,1);
  beta  = repmat(reshape(beta,1,[]),ap2,1);
  
  G.gamma = S1Grid(gamma,-maxgamma+dgamma(1,:),...
    maxgamma+dgamma(1,:),'periodic','matrix');
  
  Grid = euler2quat(alpha,beta,gamma,'ZYZ');
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
  
  G.options = {'indexed','ZYZ'};
  
end

superiorto('quaternion','rotation','orientation');
G = class(G,'SO3Grid',orientation(Grid,CS,SS));

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

function res = ori2res(ori)

if numel(ori) == 0, res = 2*pi; return;end
ml = min(numel(ori),500);
ind1 = discretesample(numel(ori),ml);
ind2 = discretesample(numel(ori),ml);
d = angle_outer(ori(ind1),ori(ind2));
d(d<0.005) = pi;
res = quantile(min(d,[],2),min(0.9,sqrt(ml/numel(ori))));
