function v = mdoe(SO3VF,varargin)
%
% Syntax
%   f = mdoe(SO3VF)
%
% Output
%   v - @vector3d
%

res = get_option(varargin,'resolution',2.5*degree);
nodes = equispacedSO3Grid(SO3VF.SRight,SO3VF.SLeft,'resolution',res);
v = mdoe(SO3VF.eval(nodes(:)));
if isalmostreal(v.xyz,'componentwise')
  v = vector3d(real(v.xyz));
end

if check_option(SO3VF.tangentSpace,'right')
  v = SO3TangentVector(v,'right');
else
  v = SO3TangentVector(v,'left');
end

end