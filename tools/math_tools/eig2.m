function [lambda,v] = eig2(M,a12,a22)
% eigenvalue and vectors of a symmetric 2x2 matrix
%
% Syntax
%
%   lambda = eig2(M)
%
%   lambda = eig2(a11,a12,a22)
%
%
%   [v,lambda] = eig3(a11,a12,a22)
%
% Input
%  M - array of symmetric 2x2 matrix
%  a11, a12,a22 - vector of matrix elements
%
% Output
%  lambda - eigen values
%  v - eigen vectors
%

% get input
if nargin == 1
  a11 = M(1,1,:); a12 = M(1,2,:); a22 = M(2,2,:);
else
  a11 = M;
end

% input should be column vectors
a11 = a11(:).'; a12 = a12(:).'; a22 = a22(:).';

% 0 = (a11 - l)(a22-l) - a12^2 = a11 a22 - a12^2 - (a11 + a22) l 
% lambda12 = (a11 + a22)./ 2 +- sqrt((a11 + a22)^2 - 4 a11 a22 + 4a12^2   ) / 2

  for k = 1:length(a11)
    
    [v(:,:,k),lambda(:,k)] = eig([a11(k) a12(k); a12(k) a22(k)],'vector');
    
  end
  
  % for some reason Matlab eig function changes to order outputs if called
  % with two arguments - so we should do the same
  [lambda,v] = deal(v,lambda);
  
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

