function varargout = Euler(quat,varargin)
% quaternion to euler angle
%
% Description
% calculates the Euler angle for a rotation |q|
%
% Syntax
%   [alpha,beta,gamma] = Euler(quat,'ABG') -
%   [phi1,Phi,phi2] = Euler(quat) -
%   euler = Euler(quat) -
%
% Input
%  quat - @quaternion
%
% Output
%  alpha, beta, gamma  - Matthies
%  phi1, Phi, phi2     - BUNGE
%
% Options
%  ABG, ZYZ   - Matthies (alpha,beta,gamma) convention
%  BUNGE, ZXZ - Bunge (phi, Phi, phi2) convention (default)
%
% See also
% quaternion/Rodrigues

% check input
if isa(quat,'quaternion')
  qa = quat.a;
  qb = quat.b;
  qc = quat.c;
  qd = quat.d;
elseif find_type(varargin,'symmetry')
  varargout{1} = orientation.byEuler(quat,varargin{:});
  return
end


% compute Matthies Euler angle

at1 = atan2(qd,qa);
at2 = atan2(qb,qc);

alpha = at1 - at2;
beta = 2*atan2(sqrt(qb.^2+qc.^2),sqrt(qa.^2+qd.^2));
gamma = at1 + at2;

ind = isnull(beta);
alpha(ind) = 2*asin(max(-1,min(1,ssign(qa(ind)).*qd(ind))));
gamma(ind) = 0;

% transform to right convention

conventions = {'nfft','ZYZ','ABG','Matthies','Roe','Kocks','Bunge','ZXZ','Canova'};
convention = get_flag(varargin,conventions,getMTEXpref('EulerAngleConvention'));

switch lower(convention)

  case {'matthies','nfft','zyz','abg'}

    labels = {'alpha','beta','gamma'};

  case 'roe'

    labels = {'Psi','Theta','Phi'};

  case {'bunge','zxz'}

    labels = {'phi1','Phi','phi2'};

    ind = ~isnull(beta);
    alpha(ind) = alpha(ind) + pi/2;
    gamma(ind) = gamma(ind) + 3*pi/2;


  case {'kocks'}

    labels = {'Psi','Theta','phi'};
    ind = ~isnull(beta);
    gamma(ind) = pi - gamma(ind);


  case {'canova'}

    labels = {'omega','Theta','phi'};
    ind = ~isnull(beta);
    alpha(ind) = pi/2 - alpha(ind);
    gamma(ind) = 3*pi/2 - gamma(ind);

end

alpha = mod(alpha,2*pi);
gamma = mod(gamma,2*pi);

if nargout == 0

  d = [alpha(:) beta(:) gamma(:)]/degree;
  d(abs(d)<1e-10)=0;

  if isa(quat,'rotation')
    i = isImproper(quat);
    d = [d,i(:)];
    labels = [labels,{'Inv.'}];
  end

  disp(' ');
  disp(['  ' convention ' Euler angles in degree'])
  cprintf(d,'-L','  ','-Lc',labels);
  disp(' ');

elseif nargout <= 2

  varargout{1} = [alpha(:),beta(:),gamma(:)];
  varargout{2} = labels;

else

  varargout{1} = alpha;
  varargout{2} = beta;
  varargout{3} = gamma;
  varargout{4} = labels;

end

function y = ssign(x)

y = ones(size(x));
y(x<0) = -1;
