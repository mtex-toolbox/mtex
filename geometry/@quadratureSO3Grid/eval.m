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

ensureCompatibleSymmetries(SO3F,SO3G)

if SO3G.CS.multiplicityPerpZ * SO3G.CS.multiplicityPerpZ == 1
  % no further symmetry can be used
  v = eval(SO3F,SO3G.nodes(:));
else
  [u,~,iu] = uniqueQuadratureSO3Grid(SO3G);
  v = reshape(SO3F.eval(u),[],length(SO3F));
  v = v(iu,:);
end

if length(SO3F)==1 && ~strcmp(SO3G.evalShape,'vector') 
  v = reshape(v,size(SO3G));
end

end