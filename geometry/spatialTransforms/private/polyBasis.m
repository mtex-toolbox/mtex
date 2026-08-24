function B = polyBasis(x,y,degree)
% the design matrix of a bivariate polynomial in x and y
%
% Written out per degree rather than generated, because the generic form
% costs a full size temporary for x.^1 and there are only two degrees.
%
% Syntax
%
%   B = polyBasis(x,y,1)   % [1 x y]
%   B = polyBasis(x,y,2)   % [1 x y x^2 xy y^2]
%
% Input
%  x, y   - n × 1 positions
%  degree - 1 or 2
%
% Output
%  B - n × m design matrix
%
% See also
% spatialTransformPoly robustLsq

x = x(:); y = y(:);

switch degree

  case 1
    B = [ones(size(x)), x, y];

  case 2
    B = [ones(size(x)), x, y, x.*x, x.*y, y.*y];

  otherwise
    error('MTEX:spatialTransform:badDegree',...
      'A polynomial displacement is fitted at degree 1 or 2, got %g.',degree);

end

end
