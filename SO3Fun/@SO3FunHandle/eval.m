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


% change evaluation method to quadratureSO3Grid.eval
if isa(rot,'quadratureSO3Grid') && strcmp(rot.scheme,'ClenshawCurtis') && contains(func2str(SO3F.fun),'eval')
  rot.evalShape = 'vector';
  f = SO3F.fun(rot);
  if numel(f)==length(rot)
    f = reshape(f,size(rot));
  end
elseif isa(rot,'quadratureSO3Grid')
  f = quadratureSO3Grid.eval(SO3F,rot,varargin{:});
  return  
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