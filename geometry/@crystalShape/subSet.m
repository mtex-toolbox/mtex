function cS = subSet(cS,NSelect)

 
N = cS.N(:);
if cS.habitus >0
  N = N ./ ((abs(N.h) * cS.extension(1)).^cS.habitus + ...
    (abs(N.k) * cS.extension(2)).^cS.habitus + ...
    (abs(N.l) * cS.extension(3)).^cS.habitus).^(1/cS.habitus);
end
N = unique(N.symmetrise,'noSymmetry','stable');

ind = any(angle_outer(N,NSelect,'noSymmetry')<1*degree,2);

F = reshape(cS.F,[],size(cS.V,2),size(cS.F,2));
cS.F = reshape(F(ind,:,:),[],size(F,3));
