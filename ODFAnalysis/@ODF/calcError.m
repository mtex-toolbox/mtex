function e = calcError(odf1,odf2,varargin)
% calculate approximation error between two ODFs
%
% Syntax
%   e = calcError(odf1,odf2)
%   e = calcError(odf,pf,'RP')
%
% Input
%  odf1, odf2 - @ODF
%  pf   - @PoleFigure
%  S3G  - @SO3Grid of quadrature nodes (optional)
%
% Options
%  L0 - measure of the orientation space where $|odf1 -- odf2|>\epsilon|
%  L1 - L^1 error 
%  L2 - L^2 error
%  RP - RP  error (default)
%  resolution - resolution used for calculation of the error
%
% See also
% PoleFigure/calcODF PoleFigure/calcError 

% compare with a pole figure
if isa(odf2,'PoleFigure'), e = calcError(odf2,odf1,varargin{:}); return;end

evaluated = ~check_option([{odf2} varargin],'evaluated');

% compare two odfs
if evaluated
  assert(odf1.CS.Laue == odf2.CS.Laue && odf1.SS.Laue == odf2.SS.Laue,...
    'Input ODFs does not have same symmetry.');
end

% TODO
% Fourier based algorithm
if check_option(varargin,'L2')
  
  e = norm(odf1 - odf2)./norm(odf2);

% quadrature  rule based algorithm
else
  
  % get approximation grid
  S3G = extract_SO3grid(odf1,'resolution',5*degree,varargin{:});

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
      e(i) = sum(abs(d1(:)-d2(:)) > epsilon(i))/numel(d1);
    end
  elseif check_option(varargin,'L2')
    e = norm(d1(:)-d2(:)) / norm(d2(:));
  else
    e = sum(abs(d1(:)-d2(:))) / numel(d1) /2;
  end
end
