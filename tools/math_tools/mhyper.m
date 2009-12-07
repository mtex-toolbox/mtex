function [f,iters] = mhyper(kappa)
% multivariat hypergeometric function 1F1(1/2,2, kappa)
%
% reference:
% G. HILLIER, R. KAN, and X. WANG: 
%   Computationally Efficient Recursions for Top-Order Invariant 
%   Polynomials with Applications
%   in Econometric Theory, 25(1), 211-242, 2009. 
%   http://www.rotman.utoronto.ca/~kan/papers/zonal5.pdf
% with many thanks to Raymond Kan
%

% corresponds to 1/b, where  b is the second argument of 1F1
c = 1/2;
s = length(kappa);

p = poly(kappa);  % characteristic polynomial of matrix X  (with roots a_i)
p = p(end:-1:2);  % eliminate leading coefficient and reflect

% initial values
d = repmat(c,s,1);
f = 1;

% the first few steps are a little different
for i = 1:s-1    
    d(i+1) = (-(i:2*i-1).*p(s-i+1:end))*d(1:i)/(2*i);
    f = f + d(i+1);
    d = d/(2+i);    
end

% the main iteration, note the cyclic shift of the entries of vector d
while max(abs(d))/(abs(f)+1) > eps
  d = [d(2:end); (-(2*i-s:2*i-1).*p)*d/(2*i)];
  f = f + d(end);
  d = d/(2+i);
   
  i=i+1;     
end

iters = i-s+1;
