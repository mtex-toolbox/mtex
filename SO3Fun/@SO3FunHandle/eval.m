function f = eval(SO3F,rot,varargin)
% evaluate a SO3FunHandle in rotations
% 
% Syntax
%   f = eval(F,rot)
%
% Input
%   SO3F - @SO3FunHandle
%   rot - @rotation (evaluation nodes)
%
% Output
%   f - double
%
% See also
% SO3FunHarmonic/eval


%     if isa(rot,'orientation')
%       ensureCompatibleSymmetries(SO3F,rot)
%     end

f = SO3F.fun(rot);

if isalmostreal(f)
  f = real(f);
end

end