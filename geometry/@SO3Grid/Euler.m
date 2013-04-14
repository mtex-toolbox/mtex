function varargout = Euler(S3G,varargin)
% convert SO3Grid to Euler angles
%
%% Syntax
%
%  [phi1,Phi,phi2] = Euler(S3G,'Bunge');
%  abg = Euler(S3G);
%
%% Input
%  S3G - @SO3Grid
%
%% Options
%  ZYZ, ABG   - Matthies (alpha, beta, gamma) convention (default)
%  ZXZ, BUNGE - Bunge (phi1,Phi,phi2) convention %
%
%% See also
% quaternion/Euler


if ~isa(S3G,'SO3Grid')
  ind = cellfun(@(x) isa(x,'SO3Grid'),varargin);
  varargin = varargin(~ind);
  [varargout{1:nargout}] = Euler(quaternion(S3G),varargin{:});
  return
end

% get convention
[convention,labels] = EulerAngleConvention(varargin{:});
S3GOptions = get(S3G,'options');
S3GConvention = EulerAngleConvention(S3GOptions{:});

if isempty(S3G.center) && ~isempty(S3G.alphabeta) && checkEulerAngleConvention(S3GConvention,convention)

  if isa(S3G.alphabeta,'double')

    alpha = S3G.alphabeta(:,1);
    beta = S3G.alphabeta(:,2);
    gamma = S3G.alphabeta(:,3);

  else

    [sbeta,salpha] = polar(S3G.alphabeta);
    gamma = double(S3G.gamma);
    igamma = cumsum([0,GridLength(S3G.gamma)]);
    alpha = zeros(length(gamma),1);
    beta = zeros(length(gamma),1);
    for i = 1:length(salpha);
      alpha(1+igamma(i):igamma(i+1)) = salpha(i);
      beta(1+igamma(i):igamma(i+1)) = sbeta(i);
    end

  end

  if check_option(varargin,'nfft')

    alpha = fft_rho(alpha);
    if getMTEXpref('nfft_bug')
      beta  = fft_theta(-beta);
    else
      beta  = fft_theta(beta);
    end
    gamma = fft_rho(gamma);
    varargout{1} = 2*pi*[alpha(:),beta(:),gamma(:)].';


  elseif nargout == 3

    varargout{1} = alpha;
    varargout{2} = beta;
    varargout{3} = gamma;

  elseif nargout == 1

    varargout{1} = [alpha(:),beta(:),gamma(:)];

  else

    d = vertcat(S3G.alphabeta)/degree;
    d(abs(d)<1e-10)=0;

    disp(' ');
    disp(['  ' convention ' Euler angles in degree'])
    cprintf(d,'-L','  ','-Lc',labels);
    disp(' ');

  end

else

  [varargout{1:nargout}] = Euler(quaternion(S3G),varargin{:});

end
