function psi = mrdivide(psi,s)
% overload the / operator, i.e. one can now write @S2Kernel / 2  in order
% to scale an S2Kernel.
%
% Syntax
%   psi = psi / 2
% 
% Input
%  psi - @S2Kernel
%  s    - constant, vector
%
% Output
%  psi - @S2Kernel
%
% See also
% S2Kernel/plus S2Kernel/mtimes
%
% See also

if ~isnumeric(s)
  error('Second argument has to be numeric. Use ./ instead.')
end

psi = times(1/s,psi);

end


