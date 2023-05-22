function out = isalmostreal(A,varargin)
% Check whether an array A is nearly real valued or not.
% Therefore an array with very small imaginary part is also seen as real
% valued.
%
% Syntax
%   out = isalmostreal(A)
%   out = isalmostreal(A,'norm',Inf)
%   out = isalmostreal(A,'norm',2,'precision',10)
%
% Input
%  A - double
%
% Output
%  out - logical
%
% Options
%  precision - exponential treshold
%  norm      - is used to compare the real and imaginary parts of A (default 1)
%

if isa(A,'vector3d')
  A = A.xyz;
end

A = A(~isnan(A));
re = real(A(:));
im = imag(A(:));

p = 10^-get_option(varargin,'precision', 5);
n = get_option(varargin,'norm', 1);

if check_option(varargin,'componentwise')
  out = any(abs(im) <= p * abs(re));
  return
end

out = norm(im,n) <= p * norm(re,n);

end