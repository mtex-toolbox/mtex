function v = eval(SO3F,SO3G,varargin)
% evaluate an SO3Fun efficently on a quadratureSO3Grid
%
% Syntax
%   v = eval(SO3F,SO3G)
%
% Input
%  SO3F - @SO3Fun
%  SO3G - @quadratureSO3Grid
%
% Output
%  v - double
%

if SO3G.CS.multiplicityPerpZ * SO3G.CS.multiplicityPerpZ == 1
  % no further symmetry can be used
  v = eval(SO3F,SO3G.nodes);
  return
end

[u,~,iu] = uniqueQuadratureSO3Grid(SO3G);
v = SO3F.eval(u);
v = v(iu);

end