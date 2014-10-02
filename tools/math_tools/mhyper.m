function y = mhyper(kappa)
% multivariat hypergeometric function 1F1(1/2,p/2, kappa)
%
% reference:
% G. HILLIER, R. KAN, and X. WANG:
%   Computationally Efficient Recursions for Top-Order Invariant
%   Polynomials with Applications
%   in Econometric Theory, 25(1), 211-242, 2009.
%   http://www.rotman.utoronto.ca/~kan/papers/zonal5.pdf
% with many thanks to Raymond Kan
%

s = length(kappa);
p = poly(kappa);          % characteristic polynomial of matrix X  (with roots a_i)
p = fliplr(p(2:end)); % eliminate leading coefficient and reflect

% corresponds to 1/b, where  b is the second argument of 1F1
beta1 = s/2;
d = ones(s,1)/beta1;

y = 1;
% the first few steps are a little different
for i=1:s-1
  d(i+1) = (-((i:2*i-1)./(2*i)).*p(s-i+1:s))*d(1:i);
  y = y+d(i+1);
  d = d/(beta1+i);
end

circshift = mod(1:s,s)+1;

kp = (-s:-1)/2.*p;

% the main iteration, note the cyclic shift of the entries of vector d
while norm(d) > eps
  i = i+1;
  
  d(1) = (-(kp/i+p))*d;
  y = y + d(1);
  d = d(circshift)/(beta1+i);
end



