function grains = subSet(grains,ind)
% 
%
% Input
%  grains - @grainSet
%  ind    - 
%
% Ouput
%  grains - @grainSet
%

ng = size(grains.I_DG,2);

% ignore empty grains
mapping = find(any(grains.I_DG,1));
mapping = mapping(ind);
  
D = sparse(mapping,mapping,1,ng,ng);
old_D = any(grains.I_DG,2);
  
grains.I_DG = grains.I_DG*D;
%   grains.A_G  = grains.A_G*D;
grains.meanRotation = grains.meanRotation(ind);
%   grains.gphase = grains.gphase(s);
    
D = double(diag(any(grains.I_DG,2)));
  
grains.A_Db = grains.A_Db*D;
grains.A_Do = grains.A_Do*D;
grains.I_FDext = grains.I_FDext*D;
grains.I_FDint = grains.I_FDint*D;

ebsd_subs = nonzeros(cumsum(old_D) .* any(grains.I_DG,2));
grains.ebsd = subsref(grains.ebsd,ebsd_subs);
  
D = any(grains.I_FDext | grains.I_FDint,2);
grains.F(~D,:) = 0;
  
[~,~,v] = find(double(grains.F));
D = sparse(v,1,1,size(grains.V,1),1)>0;
grains.V(~D,:) = 0;

end