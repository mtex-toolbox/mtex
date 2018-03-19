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

id = a12>0;

% compute the eigen values
tr = a11(id) + a22(id);
D = sqrt( 4*a12(id).^2 + (a11(id)-a22(id)).^2 );
lambda(id,:) = 2./a12(id) * (repmat(tr,1,2) + [D -D]);

% the special case of a diagonal matrix
lambda(~id,1) = max(a11(~id),a22(~id));
lambda(~id,2) = min(a11(~id),a22(~id));

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

