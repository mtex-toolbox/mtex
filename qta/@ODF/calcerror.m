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
%  L0 - measure of the orientation space where |odf1 - odf2|>epsilon
%  L1 - L^1 error (default)
%  L2 - L^2 error
%  RP - RP  error
%  resolution - resolution used for calculation of the error
%
%% See also
% PoleFigure/calcODF PoleFigure/calcerror 

%% compare with a pole figure
if isa(odf2,'PoleFigure'), e = calcerror(odf2,odf1,varargin{:}); return;end

%% compare two odfs

% check for equal symmetries
error(nargchk(2, inf, nargin))

evaluated = ~check_option([{odf2} varargin],'evaluated');

if evaluated
  CS1 = odf1(1).CS; SS1 = odf1(1).SS; 
  CS2 = odf2(1).CS; SS2 = odf2(1).SS; 
  assert(CS1 == CS2 && SS1 == SS2,'Input ODFs does not have same symmetry.');
end

% Fourier based algorithm
if check_option(varargin,'Fourier') && check_option(varargin,'L2')
  
  L = get_option(varargin,'bandwidth',min(bandwidth(odf1),bandwidth(odf2)));
  f1_hat = Fourier(odf1,'bandwidth',L,'l2-normalization');
  f2_hat = Fourier(odf2,'bandwidth',L,'l2-normalization');

  e = norm(f1_hat - f2_hat)./norm(f2_hat);

% quadrature  rule based algorithm
else
  
  % get approximation grid
  S3G = extract_SO3grid(odf1,varargin{:},'resolution',5*degree);

  % eval ODFs
  if evaluated %second ODF allready evaluated
    d1 = eval(odf2,S3G,varargin{:});
  else
    d1 = get_option([{odf2} varargin],'evaluated',[],'double');
  end
  
  if isa(odf2,'double')
    d2 = odf1;
  else
    d2 = eval(odf1,S3G,varargin{:});
  end

  % calculate the error
  if check_option(varargin,'L0')
    epsilon = get_option(varargin,'L0',1);
    for i = 1:length(epsilon)
      e(i) = sum(abs(d1-d2) > epsilon(i))/numel(d1);
    end
  elseif check_option(varargin,'L2')
    e = norm(d1-d2) / norm(d2);
  else
    e = sum(abs(d1-d2)) / length(d1) /2;
  end
end
