function c = times(a,b)
% implements e .* c and c .* e
%
% Description
% If |e| is a matrix of embeddings and |c| is a matrix of coefficients 
% then |e .* c| is again a matrix of embeddings defined by
% 
% $$ [\mathrm{e .* c}]_{j\ell} = mathrm{e}_{j\ell} \mathrm{c}_{j \ell}$$
%
% Syntax
%   out = e .* c
%   out = c .* e
%   out = e1 .* e2
%
% Input
%  e, e1, e2 - @embedding
%  c - double
%
% Output
%  out- @embedding
%

if isa(a,'embedding')
  
  if isa(b,'embedding')

    for i = 1:length(a.u), a.u{i} = a.u{i} .* b.u{i}; end
    
  else
    for i = 1:length(a.u), a.u{i} = a.u{i} .* b; end
  end
  c = a;
  
else
  
  for i = 1:length(b.u), b.u{i} = a .* b.u{i}; end
  c = b;
  
end

end