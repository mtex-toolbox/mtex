function f = eval(SO3F,rot,varargin)

% change evaluation method to quadratureSO3Grid/eval
if isa(rot,'quadratureSO3Grid')
  f = eval(SO3F,rot,varargin);
  return
end

%     if isa(rot,'orientation')
%       ensureCompatibleSymmetries(SO3F,rot)
%     end

s = size(rot);
rot = rot(:);
f = SO3F.fun(rot);
if numel(f)==length(rot)
  f = reshape(f,s);
end
if isalmostreal(f)
  f = real(f);
end
end