function l = legendre0(N,x)
% Evaluate all Legendre polynomials up to degree N in x and returns a 
% matrix of the function values
%       1st dimension -> degree
%       2nd dimension -> x
% Use the recurrence formula
%   (n+1)*P_{n+1} = (2n+1)*x*P_n - n*P_{n-1}
%
% Syntax
%   l = legendre0(N,x)
%
% Input
%   N - degree
%   x - input nodes
%   
% Output
%   l - function evaluations
%
% Example
%   x = -1:0.2:1
%   l = legendre0(10,x)
%
%   % compare with MATLABs legendre, whose first row is the Legendre
%   % polynomial of degree k
%   err = 0;
%   for k = 0:10
%     P = legendre(k,x);
%     err = max(err,max(abs(P(1,:) - l(k+1,:))));
%   end
%   err
%

x = x(:).';
l = zeros(N+1,length(x));
l(1,:) = 1;
if N == 0, return; end
l(2,:) = x;
if N == 1, return; end
l(3,:) = (3*x.^2 - 1)/2;

for i = 2:N-1
    l(i+2,:) = ((2*i+1) * x .* l(i+1,:) - (i) * l(i,:))/(i+1);
end

