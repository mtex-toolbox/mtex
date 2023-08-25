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


% change evaluation method for quadratureSO3Grid
if isa(rot,'quadratureSO3Grid')
  f = SO3F.fun(rot);
else
  s = size(rot);
  rot = rot(:);
  f = SO3F.fun(rot);
  if numel(f)==length(rot)
    f = reshape(f,s);
  end
end


if isalmostreal(f)
  f = real(f);
end

end