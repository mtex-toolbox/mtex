function e = calcerror(odf1,odf2,varargin)
% calculate approximation error between two ODFs
%
%% Syntax
%  e = calcerror(odf1,odf2)
%  e = calcerror(odf,pf,'RP')
%
%% Input
%  odf1, odf2 - @ODF
%  pf   - @PoleFigure
%  S3G  - @SO3Grid of quadrature nodes (optional)
%
%% Options
%  L1 - l^1 error (default)
%  L2 - l^2 error
%  RP - RP  error
%
%% See also
% PoleFigure/calcODF PoleFigure/calcerror 

%% compare with a pole figure
if isa(odf2,'PoleFigure'), e = calcerror(odf2,odf1,varargin{:}); return;end

%% compare two odfs

% check for equal symmetries
error(nargchk(2, inf, nargin))
[CS1,SS1] = getSym(odf1); [CS2,SS2] = getSym(odf2);
mtex_assert(CS1 == CS2 && SS1 == SS2,'Input ODFs does not have same symmetry.');

% Fourier based algorithm
if check_option(varargin,'Fourier') && check_option(varargin,'L2')
  
  L = get_option(varargin,'bandwidth',min(bandwidth(odf1),bandwidth(odf2)));
  f1_hat = Fourier(odf1,'bandwidth',L,'l2-normalization');
  f2_hat = Fourier(odf2,'bandwidth',L,'l2-normalization');

  e = norm(f1_hat - f2_hat)./norm(f2_hat);

% quadrature  rule based algorithm
else
  
  % get approximation grid
  if check_option(varargin,'resolution')
    S3G = SO3Grid(get_option(varargin,'resolution'),odf1(1).CS,odf1(1).SS);
  else
    if GridLength(getgrid(odf1)) > GridLength(getgrid(odf2))
      S3G = getgrid(odf1);
    else
      S3G = getgrid(odf2);
    end
    S3G = get_option(varargin,'SO3Grid',S3G,'SO3Grid');
  end

  % eval ODFs
  d1 = eval(odf2,S3G,varargin{:});
  if isa(odf2,'double')
    d2 = odf1;
  else
    d2 = eval(odf1,S3G,varargin{:});
  end

  % calculate the error
  if check_option(varargin,'L2')
    e = norm(d1-d2) / norm(d2);
  else
    e = sum(abs(d1-d2)) / length(d1) /2;
  end
end
