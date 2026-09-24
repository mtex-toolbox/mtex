function d = wignerdHalfPi(L)
% the Wigner-d matrices at beta = pi/2 of the degrees 0..L
%
% Description
% The matrices expm(-pi/2*Jy_l) of the degrees l = 0..L from the three term
% recursion of the quadrant S(a,b) = d_l(-a,-b), a,b >= 0, see
% SO3Fun/@SO3FunHarmonic/private/wigner_d_quadrant_at_pi_half.cpp. Those of
% any beta follow as
%
%   d_l(beta) = (-1)^floor((r-c)/2) .* (d_l(pi/2).' * ((cos(m*beta)+sin(m*beta)) .* d_l(pi/2)))
%
% with m = (-l:l)' and the row and column orders r, c.
%
% Syntax
%   d = wignerdHalfPi(L)
%
% Input
%  L - maximum degree
%
% Output
%  d - cell, d{l+1} is the (2l+1) x (2l+1) matrix of degree l
%

persistent keep
if numel(keep) > L, d = keep(1:L+1); return, end

Q = cell(1,L+1);
Q{1} = 1;
if L >= 1, Q{2} = [0, sqrt(0.5); -sqrt(0.5), 0.5]; end
for l = 2:L
  a = (0:l-1).';
  inv = 1./(l^2 - a.^2);
  p = -a.*sqrt(inv);
  q = sqrt(((l-1)^2 - a.^2).*inv);
  S1 = Q{l}(1:l,1:l);
  S2 = zeros(l); S2(1:l-1,1:l-1) = Q{l-1};
  S = zeros(l+1);
  S(1:l,1:l) = (-(2*l-1)/(l-1))*(p*p.').*S1 + (-l/(l-1))*(q*q.').*S2;
  % frame: column l is sqrt(binom(2l,l-a)) 2^-l, kept as mantissa and exponent
  S(l+1,l+1) = pow2(1,-l);
  mant = 1; ex = 0;
  for it = 1:l
    [mant,e] = log2(mant*sqrt((2*l+1-it)/it));
    ex = ex + e;
    S(l+1-it,l+1) = pow2(mant,ex-l);
  end
  S(l+1,1:l) = (1-2*mod(l+(0:l-1),2)) .* S(1:l,l+1).';
  Q{l+1} = S;
end

% the whole matrix from d(-r,c) = (-1)^(l+r+c) d(r,c) in both indices, and
% the sign (-1)^x of every positive row and column index x of expm(-pi/2*Jy_l)
d = cell(1,L+1);
for l = 0:L
  r = (-l:l).'; c = -l:l;
  D = zeros(2*l+1);
  D(1:l+1,1:l+1) = rot90(Q{l+1},2);
  D(l+2:end,1:l+1) = (1-2*mod(l+r(l+2:end)+c(1:l+1),2)) .* D(l:-1:1,1:l+1);
  D(:,l+2:end) = (1-2*mod(l+r+c(l+2:end),2)) .* D(:,l:-1:1);
  sigma = 1 - 2*(r > 0 & mod(r,2)==1);
  d{l+1} = (sigma*sigma.') .* D;
end
keep = d;

end
