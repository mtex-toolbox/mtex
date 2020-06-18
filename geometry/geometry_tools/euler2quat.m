function q = euler2quat(alpha,beta,gamma,varargin)
% converts euler angle to quaternion
%
% Description
% The method *euler2quat* defines a @quaternion by Euler angles. You can
% choose whether to use the Bunge (phi,Phi,phi2) convention or the Matthies
% (alpha,beta,gamma) convention.
%
% Syntax
%
%   q = euler2quat(alpha,beta,gamma) -
%   q = euler2quat(phi1,Phi,phi2,'Bunge') -
%
% Input
%  alpha, beta, gamma - double
%  phi1, Phi, phi2    - double
%
% Output
%  q - @quaternion
%
% Options
%  ABG, ZYZ   - Matthies (alpha, beta, gamma) convention (default)
%  BUNGE, ZXZ - Bunge (phi1,Phi,phi2) convention
%
% See also
% quaternion/quaternion quaternion/quaternion axis2quat Miller2quat
% vec42quat hr2quat

% maybe euler angles are given as a matrix
if nargin == 1 || (size(alpha,2)==3 && ~isnumeric(beta))
  if exist('beta','var') && isa(beta,'char')
      varargin = [varargin beta];
  end
  if exist('gamma','var') && isa(gamma,'char')
    varargin = [varargin gamma];
  end
  
  gamma = alpha(:,3);
  beta = alpha(:,2);
  alpha = alpha(:,1);

end

% may forgotten * degree
if any([alpha(:);beta(:);gamma(:)] > 9)
  warning('Some Euler angles appears to be quite large. Maybe you forgot ''* degree'' to switch from degree to radians.');
end

% transform to right convention

conventions = {'nfft','ZYZ','ABG','Matthies','Roe','Kocks','Bunge','ZXZ','Canova'};
convention = get_flag(varargin,conventions,getMTEXpref('EulerAngleConvention'));

switch lower(convention)

  case {'matthies','nfft','zyz','abg'}

  case 'roe'

  case {'bunge','zxz'}  % Bunge -> Matthies

    alpha = alpha - pi/2;
    gamma = gamma - 3*pi/2; % According to Kocks, this should be pi/2 + gamma

  case {'kocks'}        % Kocks -> Matthies

    gamma = pi - gamma;

  case {'canova'}       % Canova -> Matthies

    alpha = pi/2 - alpha;
    gamma = 3*pi/2 - gamma;

end


% construct quaternion

zero = zeros(size(alpha));

qalpha = quaternion(cos(alpha/2),zero,zero,sin(alpha/2));
qbeta  = quaternion(cos(beta/2),zero,sin(beta/2),zero);
qgamma = quaternion(cos(gamma/2),zero,zero,sin(gamma/2));

q = qalpha .* qbeta .* qgamma;
