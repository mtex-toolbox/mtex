function varargout = Euler(quat,varargin)
% quaternion to euler angle
%
%% Description
% calculates the Euler angle for a rotation |q|
%
%% Syntax
% [alpha,beta,gamma] = Euler(quat)
% [phi1,Phi,phi2] = Euler(quat,'Bunge')
% euler = Euler(quat,'Bunge')
%
%% Input
%  quat - @quaternion
%% Output
%  alpha, beta, gamma  - Matthies
%  phi1, Phi, phi2     - BUNGE
%% Options
%  ABG, ZYZ   - Matthies (alpha,beta,gamma) convention (default)
%  BUNGE, ZXZ - Bunge (phi, Phi, phi2) convention
%% See also
% quaternion/Rodrigues

%% check input

if isa(quat,'quaternion')
  qa = quat.a;
  qb = quat.b;
  qc = quat.c;
  qd = quat.d;
elseif find_type(varargin,'symmetry')
  varargout{1} = orientation('Euler',quat,varargin{:});
  return
end


%% compute Matthies Euler angle

alpha = atan2( qc .* qd - qa .* qb  ,  qb .* qd + qa .* qc );
beta = acos(max(-1,min(1,-qb.^2 - qc.^2 + qd.^2 + qa.^2)));
gamma = atan2( qc .* qd + qa .* qb  , -qb .* qd + qa .* qc );

% Bunges
%  gamma = atan2( qb .* qd - qa .* qc ,   qc .* qd + qa .* qb );
%  beta = acos(max(-1,min(1,-qb.^2 - qc.^2 + qd.^2 + qa.^2)));
%  alpha = atan2( qb .* qd + qa .* qc  , -qc .* qd + qa .* qb );


% if rotational axis equal to z
ind = isnull(qb) & isnull(qc);
alpha(ind) = 2*asin(max(-1,min(1,ssign(qa(ind)).*qd(ind))));
beta(ind) = 0;
gamma(ind) = 0;

%% transform to right convention

conventions = {'nfft','ZYZ','ABG','Matthies','Roe','Kocks','Bunge','ZXZ','Canova'};
convention = get_flag(varargin,conventions,get_mtex_option('EulerAngleConvention'));

switch convention
  
  case {'Matthies','nfft','ZYZ','ABG'}

    labels = {'alpha','beta','gamma'};
    
  case 'Roe'
    
    labels = {'Psi','Theta','Phi'};
    
  case {'Bunge','ZXZ'}

    labels = {'phi1','Phi','phi2'};
    if beta ~= 0
      alpha = alpha + pi/2;
      gamma = gamma + 3*pi/2;
    end
    
  case {'Kocks'}

    labels = {'Psi','Theta','phi'};
    if beta ~= 0
      gamma = pi - gamma;
    end
    
  case {'Canova'}
    
    labels = {'omega','Theta','phi'};
    if beta ~= 0
      alpha = pi/2 - alpha;
      gamma = 3*pi/2 - gamma;
    end
    
end

alpha = mod(alpha,2*pi);
gamma = mod(gamma,2*pi);

if nargout == 0
  
  d = [alpha(:) beta(:) gamma(:)]/degree;
  d(abs(d)<1e-10)=0;
  
  disp(' ');
  disp(['  ' convention ' Euler angles in degree'])
  cprintf(d,'-L','  ','-Lc',labels);
  disp(' ');
  
elseif check_option(varargin,'nfft')
  
  alpha = fft_rho(alpha);
  beta  = fft_theta(-beta);
  gamma = fft_rho(gamma);
  varargout{1} = 2*pi*[alpha(:),beta(:),gamma(:)].';
  
elseif nargout == 1
  
  varargout{1} = [alpha(:),beta(:),gamma(:)];
  
else
  
  varargout{1} = alpha;
  varargout{2} = beta;
  varargout{3} = gamma;
  
end

function y = ssign(x)

y = ones(size(x));
y(x<0) = -1;
