function [lambda,v] = eig2(M,varargin)
% eigenvalue and vectors of a symmetric 2x2 matrix
%
% Syntax
%
%   lambda = eig2(M)
%
%   lambda = eig2(a11,a12,a22)
%
%
%   [omega,lambda] = eig2(a11,a12,a22)
%
% Input
%  M - array of symmetric 3x3 matrix
%  a11, a12,a22 - vector of matrix elements
%
% Output
%  lambda - eigen values
%  v - eigen vectors
%  omega - angle of the largest eigen vector
%

% get input
if nargin == 1 || ischar(varargin{1})
  a11 = M(1,1,:); a12 = M(1,2,:); a22 = M(2,2,:);
else
  a11 = M; a12 = varargin{2}; a22 = varargin{3};
end

% input should be column vectors
a11 = a11(:).'; a12 = a12(:).'; a22 = a22(:).';

% compute the eigen values
lambda = [2 * ( a11 + a22 + sqrt( 4*a12.^2 + (a11-a22).^2 )) ./a12,  ...
  2 * ( a11 + a22 - sqrt(4*a12.^2 + (a11-a22).^2 ))./a12];

if nargout > 1

  omega = 0.5 * atan2(2*a12,a11-a22);

  if check_option(varargin,'angle')
    v = omega;
  else
    v = [cos(omega) sin(omega)];
  end
      
  % for some reason Matlab eig function changes to order outputs if called
  % with two arguments - so we should do the same
  [lambda,v] = deal(v,lambda);
  
end

end

