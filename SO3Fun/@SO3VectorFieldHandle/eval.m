function f = eval(SO3VF,ori,varargin)
% evaluate the SO3VectorFieldHandle in rotations
% 
% Syntax
%   f = eval(SO3VF,rot)         % left tangent vector
%   f = eval(SO3VF,rot,'right') % right tangent vector
%
% Input
%   rot - @rotation
%
% Output
%   f - @vector3d
%
% See also
%


% if isa(ori,'orientation')
% ensureCompatibleSymmetries(SO3VF,ori)
% end


% change evaluation method to quadratureSO3Grid.eval
if isa(ori,'quadratureSO3Grid') && strcmp(ori.scheme,'ClenshawCurtis') && contains(func2str(SO3VF.fun),'eval')
  f = SO3VF.fun(ori);
elseif isa(ori,'quadratureSO3Grid')
  f = quadratureSO3Grid.eval(SO3VF,ori,varargin{:});
  return  
else
  s = size(ori);
  ori = ori(:);
  f = SO3VF.fun(ori);
  if length(f)==length(ori)
    f = reshape(f,s);
  end
end

% Make output right/left deendent from the input flag
f = SO3TangentVector(f,SO3VF.tangentSpace);
if check_option(varargin,'right')
  f = right(f,ori);
end
if check_option(varargin,'left')
  f = left(f,ori);
end

end