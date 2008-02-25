function e = calcerror(rec,orig,varargin)
% calculate approximation error between a true and a recalculated ODF
%
%% Input
%  rec  - reconstructed @ODF
%  orig - true @ODF
%  S3G  - @SO3Grid of quadrature nodes (optional)
%
%% Options
%  L1 - l^1 error (default)
%  L2 - l^2 error
%
%% See also
% PoleFigure/calcODF PoleFigure/calcerror 

if check_option(varargin,'fourier') && check_option(varargin,'L2')
  
  L = get_option(varargin,'bandwidth',min(bandwidth(rec),bandwidth(orig)));
  f1_hat = fourier(rec,'bandwidth',L,'l2-normalization');
  f2_hat = fourier(orig,'bandwidth',L,'l2-normalization');

  e = norm(f1_hat - f2_hat)./norm(f2_hat);
  
else
  if check_option(varargin,'resolution')
    S3G = SO3Grid(get_option(varargin,'resolution'),rec(1).CS,rec(1).SS);
  else
    S3G = get_option(varargin,'SO3Grid',getgrid(rec),'SO3Grid');
  end

  d1 = eval(rec,S3G,varargin{:});
  if isa(orig,'double')
    d2 = orig;
  else
    d2 = eval(orig,S3G,'EXACT');
  end

  if check_option(varargin,'L2')
    e = norm(d1-d2) / norm(d2);
  else
    e = sum(abs(d1-d2)) / length(d1) /2;
  end
end
