function psi = mrdivide(psi,s)
% overload the / operator, i.e. one can now write @SO3Kernel / 2  in order
% to scale an SO3Kernel.
%
% Syntax
%   psi = psi / 2
% 
% Input
%  psi - @SO3Kernel
%  s    - constant, vector
%
% Output
%  psi - @SO3Kernel
%
% See also
% SO3Kernel/plus SO3Kernel/mtimes
%
% See also

if ~isnumeric(s)
  error('Second argument has to be numeric. Use ./ instead.')
end

psi = times(1/s,psi);

end


