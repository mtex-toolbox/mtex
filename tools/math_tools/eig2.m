function [lambda,v] = eig2(M,a12,a22)
% eigenvalue and vectors of a symmetric 2x2 matrix
%
% Syntax
%
%   lambda = eig2(M)
%
%   lambda = eig2(a11,a12,a22)
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

% eigen value compution
% 0 = (a11 - l)(a22-l) - a12^2 = l^2 - (a11 + a22) l + a11 a22 - a12^2 
% lambda12 = (a11 + a22)./ 2 +- sqrt((a11 + a22)^2 - 4 a11 a22 + 4a12^2   ) / 2

p = (a11 + a22)./2;
D = real(sqrt(p.^2 - a11 .* a22 + a12.^2));
lambda(1,:) = p - D;
lambda(2,:) = p + D;

% a first eigen vector
v(1,1,:) =  -a12;
v(2,1,:) = a11 - lambda(1,:);

% its norm
n = sqrt(v(1,1,:).^2 + v(2,1,:).^2);

% maybe some of them are zero?
v(1,1,n==0) = 1;
v(2,1,n==0) = 0;
n(n==0) = 1;

% the second eigen vector is alway orthogonal
v(1,2,:) = v(2,1,:);
v(2,2,:) = -v(1,1,:);

% normalize the eigenvectors
v = v ./ repmat(reshape(n,1,1,[]),2,2);

%for k = 1:length(a11)   
%  [v(:,:,k),lambda(:,k)] = eig([a11(k) a12(k); a12(k) a22(k)],'vector');  
%end
  
% for some reason Matlab eig function changes to order outputs if called
% with two arguments - so we should do the same
[lambda,v] = deal(v,lambda);
  
end

function test

% generate random symmetric 2x2 matrixes
N = 1000000;
a = rand(3,N);

tic
[V1,lambda1] = eig2(a(1,:),a(2,:),a(3,:));
toc

tic
lambda2 = zeros(2,N);
V2 = zeros(2,2,N);
for i = 1:N
  A = [a(1,i),a(2,i);a(2,i),a(3,i)];
  [V2(:,:,i),lambda2(:,i)] = eig(A,'vector');
end
toc

norm(lambda1 - lambda2) ./ N
squeeze(sum(sum((V1 - V2).^2,1),2))

end

