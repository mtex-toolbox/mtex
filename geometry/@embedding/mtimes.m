function c = mtimes(a,b)
% implements e * c and c * e
%
% Description
% If |e| is a matrix of embeddings and |c| is a matrix of coefficients 
% then |e * c| is again a matrix of embeddings defined by
% 
% $$ [\mathrm{e * c}]_{j\ell} = \sum_{k} \mathrm{e}_{jk} \mathrm{c}_{k \ell}$$
%
% Syntax
%   out = e * c
%   out = c * e
%
% Input
%  e - @embedding
%  c - double
%
% Output
%  out- @embedding
%

if isa(a,'embedding')
  for i = 1:length(a.u)
    a.u{i} = a.u{i} * b;
  end
  c = a;
else
  for i = 1:length(b.u)
    b.u{i} = a * b.u{i};
  end
  c = b;
end

end