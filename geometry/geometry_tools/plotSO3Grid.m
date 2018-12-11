function [S3G,S2G,sec,scaling] = plotSO3Grid(CS,SS,varargin)
% give a regular grid in orientation space
%
% Syntax
%   % sections according phi2 angle
%   [S3G,S2G,phi2] = plotSO3Grid(CS,SS,'phi2')
%
%   % sections according rotational axis / angle
%   [S3G,axes,omega,scaling] = plotSO3Grid(CS1,CS2,'axisAngle')
%
% Input
%  CS - @crystalSymmetry
%  SS - @specimenSymmetry
%
% Output
%  S3G - @SO3Grid
%  S2G,axes - list of @vector3d, the plotting directions
%  phi2 - double
%  scaling - double
%

% the axis / angle grid
if check_option(varargin,{'axisAngle','angle'})
  sym = properGroup(disjoint(CS,SS));

  % get sections
  if check_option(varargin,'angle')
    sec = get_option(varargin,'angle');
  else
    sec = (5:5:180)*degree;
    sec(sec>sym.maxAngle) = [];
  end

  for i = 1:length(sec)
    S2G{i} = plotS2Grid(sym.Laue.fundamentalSector('angle',sec(i)),varargin{:}); %#ok<AGROW>
    S3G{i} = orientation.byAxisAngle(S2G{i},sec(i)); %#ok<AGROW>
  end

  S3G = [S3G{:}];
  scaling = sin(sym.maxAngle/2) ./ sin(sec/2);
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

% get bounds
[max_rho,max_theta,max_sec] = fundamentalRegionEuler(CS,SS,varargin{:});

% make the sectioning variable to be the last one
if any(strcmpi(sectype,{'alpha','phi1','Psi'}))
  dummy = max_sec; max_sec = max_rho; max_rho = dummy;
elseif strcmpi(sectype,'omega')
  max_sec = 2*pi;
end

% sections
nsec = get_option(varargin,'sections',min(18,round(max_sec/10/degree)));
sec = linspace(0,max_sec,nsec+1); sec(end) = [];
sec = get_option(varargin,sectype,sec,'double');
nsec = length(sec);

% non sectioning angles
sR = sphericalRegion('maxTheta',max_theta,'maxRho',max_rho);
S2G = plotS2Grid(sR,varargin{:});

% build size(S2G) x nsec matrix of Euler angles
sec_angle = repmat(reshape(sec,[1,1,nsec]),[size(S2G),1]);
theta  = reshape(repmat(S2G.theta ,[1,1,nsec]),[size(S2G),nsec]);
rho = reshape(repmat(S2G.rho,[1,1,nsec]),[size(S2G),nsec]);
S2G = repcell(S2G,nsec,1);

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
S3G = orientation.byEuler(sec_angle,theta,rho,convention,CS,SS);

end
