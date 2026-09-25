function SO3F = rotate_outer(SO3F,rot,varargin)
% rotate function on SO(3) by multiple rotations
%
% Syntax
%   SO3F = rotate(SO3F,rot)
%   SO3F = rotate(SO3F,rot,'right')
%
% Input
%  SO3F - @SO3FunHarmonic
%  rot  - @rotation
%
% Output
%  SO3F - @SO3FunHarmonic
%
% See also
% SO3FunHandle/rotate_outer

if check_option(varargin,'right')
  
  if isa(rot,'orientation') 
    assert(rot.SS == SO3F.CS,'symmetry missmatch');
    SO3F.CS = rot.CS;
  else
  SO3F.CS = dropSymmetry(SO3F.CS,rot,'crystal','ODF');
  end
  
else
  if isa(rot,'orientation') 
    assert(rot.CS == SO3F.SS,'symmetry missmatch');
    SO3F.SS = rot.SS;
  else
  SO3F.SS = dropSymmetry(SO3F.SS,rot,'specimen','ODF');
  end
end

% the conjugate Wigner-D matrix of degree l is diag(g) d(beta) diag(a) with
% the phases a, g of alpha and gamma, and d(beta) from the one at pi/2, see
% wignerdHalfPi; SO3F.fhat or rot may be many, as in convSO3. Without forming
% D this computes
%
%   D = conj(WignerD(rot,'bandwidth',L,'normalize'));
%   D = reshape(D,[],length(rot));
%   if check_option(varargin,'right')
%     SO3F.fhat = convSO3(SO3F.fhat,D);
%   else
%     SO3F.fhat = convSO3(D,SO3F.fhat);
%   end

L = SO3F.bandwidth;
[alpha,beta,gamma] = Euler(rot,'abg');
dHalf = wignerdHalfPi(L);
right = check_option(varargin,'right');
s = size(SO3F.fhat);
fhat = reshape(SO3F.fhat,s(1),[]);
nr = numel(alpha); nf = size(fhat,2); n = max(nr,nf);
out = zeros(deg2dim(L+1),n);
for l = 0:L
  m = (-l:l).';
  ind = deg2dim(l)+1:deg2dim(l+1);
  pm = 1 - 2*(m > 0 & mod(m,2)==1);
  sgn = (-1).^floor((m-m.')/2);
  D = dHalf{l+1};
  for k = 1:n
    i = min(k,nr);
    a = pm.*exp(1i*alpha(i)*m); g = pm.*exp(1i*gamma(i)*m);
    d = sgn .* (D.' * ((cos(m*beta(i))+sin(m*beta(i))) .* D));
    F = reshape(fhat(ind,min(k,nf)),2*l+1,2*l+1);
    if right, F = g .* (d * (a .* F)); else, F = ((F .* g.') * d) .* a.'; end
    out(ind,k) = F(:);
  end
end
if nf > 1, n = s(2:end); end
SO3F.fhat = reshape(out,[deg2dim(L+1),n]);
if isa(rot,'orientation'), SO3F = symmetrise(SO3F); end

end
