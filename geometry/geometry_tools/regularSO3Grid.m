function [SO3G,S2G,sec,angles] = regularSO3Grid(varargin)
% regular grid in Euler orientation space
%
% Syntax
%   SO3G = regularSO3Grid(cs)
%   SO3G = regularSO3Grid(cs,ss,'resolution',2.5*degree)     % specify the resolution
%   SO3G = regularSO3Grid(cs,ss,'resolution',5*degree,'ZYZ') % use ZYZ convention
%   SO3G = regularSO3Grid(cs,ss,'phi2','sections',10)        % 10 phi2 sections
%   SO3G = regularSO3Grid('ClenshawCurtis','bandwidth',64) % 
%
% Input
%  cs - @crystalSymmetry
%  ss - @specimenSymmetry
%
% Options
%  resolution - Euler angle resolution
%  sections - number of sections
%
% Flags
%  phi1 | Phi | phi2 - sections along which variable
%
% Output
%  SO3G - @orientation
%

% extract symmetry
[SRight,SLeft] = extractSym(varargin);

% get Euler angle bounds
[max_rho,max_theta,max_sec] = fundamentalRegionEuler(SRight,SLeft,varargin{:});

N = ceil(get_option(varargin,'bandwidth',256)/2);

if check_option(varargin,'GaussLegendre')
  % a regular grid for Gauss Legendre quadrature required bandwidth 2n 
  % 2n+1 Clenshaw Curtis Quadrature rule -> (2n+2)x(n+1)x(2n+2) points

  nodes = legendreNodesWeights(N+1,-1,1);
  theta = acos(nodes);
  beta =  theta(theta<max_theta+1e-8);
  alpha = 0:(2*pi)/(2*N+2):max_rho-1e-8;
  gamma = 0:(2*pi)/(2*N+2):max_sec-1e-8;

  [beta,gamma,alpha] = meshgrid(beta,gamma,alpha);
  SO3G = orientation.byEuler(alpha,beta,gamma,'nfft',SRight,SLeft);

  return

end

if check_option(varargin,'ClenshawCurtis')
  % a regular grid for ClenshawCurtis quadrature required bandwidth 2n 
  % 2n+1 Clenshaw Curtis Quadrature rule -> (2n+2)x(2n+1)x(2n+2) points

  alpha = 0:(2*pi)/(2*N+2):max_rho-1e-8;
  beta = 0:(pi)/(2*N):max_theta+1e-8;
  gamma = 0:(2*pi)/(2*N+2):max_sec-1e-8;

  [beta,gamma,alpha] = meshgrid(beta,gamma,alpha);
  SO3G = orientation.byEuler(alpha,beta,gamma,'nfft',SRight,SLeft);

  return

end


% determine sectioning type
sectypes = {...
  {'gamma','alpha','sigma','omega'},...
  {'phi2','phi1'},...
  {'omega2'},...
  {'psi'}};

conventions = {...
  {'Matthies','nfft','ZYZ','ABG'},...
  {'Bunge','ZXZ'},...
  {'Canova'},...
  {'Kocks'}};

% sectioning given
if check_option(varargin,[sectypes{:}])

  sectype = get_flag(varargin,[sectypes{:}]);
  convention = cellfun(@(x) any(strcmpi(x,sectype)),sectypes);
  convention = conventions{convention}{1};

else % convention given

  convention = get_flag(varargin,[conventions{:}],'Bunge');
  sectype = cellfun(@(x) any(strcmpi(x,convention)),conventions);
  sectype = sectypes{sectype}{1};

end

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

% no sectioning angles
S2G = regularS2Grid('maxTheta',max_theta,'maxRho',max_rho,'restrict2MinMax',varargin{:});
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
SO3G = orientation.byEuler(sec_angle,theta,rho,convention,SRight,SLeft);
% store gridding, @TODO: check when its required, this is required for
% export
if nargout == 4
  angles = [sec_angle(:),theta(:),rho(:)];
end
% S2G = [sec_angle(:),theta(:),rho(:)];

end
