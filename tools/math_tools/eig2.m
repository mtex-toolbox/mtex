function [lambda,v1,v2] = eig2(M,varargin)
% eigenvalue and vectors of a symmetric 2x2 matrix
%
% Syntax
%
%   lambda = eig2(M)
%
%   lambda = eig2(a11,a12,a22)
%
%   [lambda,v1,v2] = eig2(a11,a12,a22)
%
%   [lambda,omega] = eig2(a11,a12,a22)
%
% Input
%  M - array of symmetric 2x2 matrix
%  a11, a12, a22 - vectors of matrix elements
%
% Output
%  lambda - eigen values (first column small one, second column large one)
%  v1 - list of eigen vectors to the smallest eigen value
%  v2 - list of eigen vectors to the largest eigen value
%  omega - angle of the largest eigen vector in [0,pi]
%

% get input
if nargin == 1 || ischar(varargin{1})
  a11 = M(1,1,:); a12 = M(1,2,:); a22 = M(2,2,:);
else
  a11 = M; a12 = varargin{1}; a22 = varargin{2};
end

% input should be column vectors
a11 = a11(:); a12 = a12(:); a22 = a22(:);

% eigen value compution
% 0 = (a11 - l)(a22-l) - a12^2 = l^2 - (a11 + a22) l + a11 a22 - a12^2 
% lambda12 = (a11 + a22)./ 2 +- sqrt((a11 + a22)^2 - 4 a11 a22 + 4a12^2   ) / 2

p = (a11 + a22)./2;
D = real(sqrt(p.^2 - a11 .* a22 + a12.^2));
lambda(:,1) = p - D;
lambda(:,2) = p + D;

% compute eigen vectors
if nargout > 1

  % then angle of the largest eigen vector
  omega = atan2(a12,a11 - lambda(:,1));
 
  if nargout == 2
    v1 = mod(omega,pi); % only the range between 0 and pi matters
  else
    v1 = [-sin(omega) cos(omega)];
    v2 = [cos(omega) sin(omega)];
  end
  
end

end

function test

% generate random symmetric 2x2 matrixes
N = 10;
a = rand(3,N);

tic
[lambda1,v1,v2] = eig2(a(1,:),a(2,:),a(3,:));
toc

tic
lambda2 = zeros(N,2);
V1 = zeros(N,2);
V2 = zeros(N,2);
for i = 1:N
  A = [a(1,i),a(2,i);a(2,i),a(3,i)];
  [V,lambda2(i,:)] = eig(A,'vector');
  V1(i,:) = V(:,1);
  V2(i,:) = V(:,2);
end
toc

norm(lambda1 - lambda2) ./ N
max(abs(1-abs(sum(v1 .* V1,2))))
max(abs(1-abs(sum(v2 .* V2,2))))


end

