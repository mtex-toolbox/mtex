function [lambda,v] = eig3(M,a12,a13,a22,a23,a33,varargin)
% eigenvalue and vectors of a symmetric 3x3 matrix
%
% Syntax
%
%   lambda = eig3(M)
%
%   lambda = eig3(a11,a12,a13,a22,a23,a33)
%
%
%   [v,lambda] = eig3(a11,a12,a13,a22,a23,a33)
%
% Input
%  M - array of symmetric 3x3 matrix
%  a11, a12,a13,a22,a23,a33 - vector of matrix elements
%
% Output
%  lambda - eigen values
%  v - eigen vectors
%

% get input
if nargin == 1
  a11 = M(1,1,:); a12 = M(1,2,:); a13 = M(1,3,:);
  a22 = M(2,2,:); a23 = M(2,3,:); a33 = M(3,3,:);
else
  a11 = M;
end

s = size(a11);

% input should be column vectors
a11 = a11(:).'; a12 = a12(:).'; a13 = a13(:).';
a22 = a22(:).'; a23 = a23(:).'; a33 = a33(:).';

% Given a real symmetric 3x3 matrix A, compute the eigenvalues
p1 = a12.^2 +a13.^2 + a23.^2;

q = (a11 + a22 + a33)/3;
p2 = (a11 - q).^2 + (a22 - q).^2 + (a33 - q).^2 + 2 * p1;
p = sqrt(p2 / 6);

%r = det(A-q*Id) / 2 / p^3;
r = (a11-q) .* ( (a22-q) .* (a33-q) - a23.^2) + ...
  a12 .* (a13 .* a23 - a12 .* (a33-q)) + ...
  a13 .* (a12 .* a23 - (a22-q) .* a13);
r = r / 2 ./ p.^3;

% In exact arithmetic for a symmetric matrix  -1 <= r <= 1
% but computation error can leave it slightly outside this range.
phi = acos(r) / 3;
phi(r <= -1) = pi / 3;
phi(r >= 1) = 0;

% the eigenvalues satisfy eig3 <= eig2 <= eig1
lambda = zeros(3,numel(a11));
lambda(1,:) = q + 2 * p .* cos(phi + (2*pi/3));
lambda(3,:) = q + 2 * p .* cos(phi);
lambda(2,:) = 3 * q - lambda(1,:) - lambda(3,:);     % since trace(A) = eig1 + eig2 + eig3


if nargout > 1
  
  % this is only required for matlab versions prior to 2015
  b11 = repmat(a11,3,1); b12 = repmat(a12,3,1); b13 = repmat(a13,3,1);
  b22 = repmat(a22,3,1); b23 = repmat(a23,3,1); b33 = repmat(a33,3,1);
    
  v = vector3d(b12 .* b23 - b13 .* (b22 - lambda),...
    b13 .* b12 - (b11 - lambda) .* b23,...
    (b11 - lambda) .* (b22 - lambda) - b12 .* b12,'antipodal');
  
  v = v.normalize;
  
  % fallback for special cases
  % TODO: this should be done better
  id = ~(abs(det(v(1,:),v(2,:),v(3,:))) > (1 - 1e-5)) | isnan(lambda(1,:));  
  x = v.x; y = v.y; z = v.z;
  for k = find(id)
    
    [V,l] = eig([a11(k) a12(k) a13(k);...
      a12(k) a22(k) a23(k); ...
      a13(k) a23(k) a33(k)]);
    
    x(:,k) = V(1,:); y(:,k) = V(2,:); z(:,k) = V(3,:);
    lambda(:,k) = diag(l);
    
  end
  v.x = x; v.y = y; v.z = z;
  
  %a1 = vector3d(a11-lambda(1),a12,a13);
  %a2 = vector3d(a12,a22-lambda(1),23);
  %a3 = vector3d(a13,a23,33-lambda(1));
  
  %cross(a2,a3)

  % return only the largest eigen vector
  if check_option(varargin,'largest'), v = reshape(v(3,:),s); end
  
  % for some reason Matlab eig function changes to order outputs if called
  % with two arguments - so we should do the same
  [lambda,v] = deal(v,lambda);
  
end

end

function test

% generate random symmetric 3x3 matrixes
N = 10
a = rand(6,N);

tic
[V1,lambda1] = eig3(a(1,:),a(2,:),a(3,:),a(4,:),a(5,:),a(6,:));
toc

tic
lambda2 = zeros(3,N);
V2 = vector3d.zeros(3,N)
for i = 1:N
  A = [a(1,i),a(2,i),a(3,i);a(2,i),a(4,i),a(5,i);a(3,i),a(5,i),a(6,i)];
  [V,lambda2(:,i)] = eig(A,'vector');
  V2(1,i) = vector3d(V(:,1));
  V2(2,i) = vector3d(V(:,2));
  V2(3,i) = vector3d(V(:,3));
end
toc

norm(lambda1 - flipud(lambda2)) ./ N
max(angle(V1(:),V2(:)))

end

