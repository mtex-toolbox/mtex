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


% the two rotation angles about the z-axis and the tilt
at1 = atan2(qd,qa);
at2 = atan2(qb,qc);
beta = 2*atan2(sqrt(qb.^2+qc.^2),sqrt(qa.^2+qd.^2));

ind = isnull(beta);

% compute the first and third Euler angle explicitly for each convention -
% full vector expressions, the few beta == 0 entries are overwritten below

conventions = {'nfft','ZYZ','ABG','Matthies','Roe','Kocks','Bunge','ZXZ','Canova'};
convention = get_flag(varargin,conventions,getMTEXpref('EulerAngleConvention'));

% zSign and zShift describe how the convention encodes a pure z-rotation by
% omega once the third angle is set to zero, i.e. alpha = zSign*omega + zShift.
% They are the inverse of the convention -> Matthies map in euler2quat, which
% is all that survives at beta == 0: there the quaternion only depends on
% alphaMatthies + gammaMatthies, so the split between the two angles is
% arbitrary and only their contribution to the z-rotation is determined.

switch lower(convention)

  case {'matthies','nfft','zyz','abg'}

    labels = {'alpha','beta','gamma'};
    alpha = mod(at1 - at2,2*pi);
    gamma = mod(at1 + at2,2*pi);
    zSign = 1; zShift = 0;

  case 'roe'

    labels = {'Psi','Theta','Phi'};
    alpha = mod(at1 - at2,2*pi);
    gamma = mod(at1 + at2,2*pi);
    zSign = 1; zShift = 0;

  case {'bunge','zxz'}

    labels = {'phi1','Phi','phi2'};
    alpha = mod((at1 - at2) + pi/2,2*pi);
    gamma = mod((at1 + at2) + 3*pi/2,2*pi);
    zSign = 1; zShift = 0;         % alpha - pi/2 + gamma - 3*pi/2 == omega

  case {'kocks'}

    labels = {'Psi','Theta','phi'};
    alpha = mod(at1 - at2,2*pi);
    gamma = mod(pi - (at1 + at2),2*pi);
    zSign = 1; zShift = -pi;       % alpha + pi - gamma == omega

  case {'canova'}

    labels = {'omega','Theta','phi'};
    alpha = mod(pi/2 - (at1 - at2),2*pi);
    gamma = mod(3*pi/2 - (at1 + at2),2*pi);
    zSign = -1; zShift = 0;        % 2*pi - alpha - gamma == omega

end

% beta == 0: the rotation is a pure rotation about the z-axis by omega. Only
% the sum of the first and the third angle is determined, so put all of it
% into the first one - but in the coordinates of the convention, not in
% Matthies coordinates, which is what zSign and zShift correct for.
if any(ind(:))
  omega = 2*asin(max(-1,min(1,ssign(qa(ind)).*qd(ind))));
  alpha(ind) = mod(zSign*omega + zShift,2*pi);
  gamma(ind) = 0;
end

if nargout == 0

  d = [alpha(:) beta(:) gamma(:)]/degree;
  d(abs(d)<1e-10)=0;

  if isa(quat,'rotation') && any(isImproper(quat.subSet(':')))
    i = isImproper(quat);
    d = [d,i(:)];
    labels = [labels,{'Inv.'}];
  end

  s = getClass(varargin,'struct');
  if ~isempty(s)
    fn = fieldnames(s);
    labels = [labels,fn];
    for k = length(fn)
      d = [d,s.(fn{k})];
    end    
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
