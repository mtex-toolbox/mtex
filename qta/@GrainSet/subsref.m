function grains = subsref(grains,s)


if isa(s,'double') || isa(s,'logical')
  
  if islogical(s)
    s = find(s);    
  end
  
  ng = size(grains.I_DG,2);
  
  mapping = find(any(grains.I_DG,1));
  mapping = mapping(s);
  
  D = sparse(mapping,mapping,1,ng,ng);
  
  old_D = any(grains.I_DG,2);
  
  grains.I_DG = grains.I_DG*D;
  grains.A_G  = grains.A_G*D;
  
  grains.meanRotation = grains.meanRotation(s);
  grains.phase = grains.phase(s);
  grains.options = structfun(@(x) x(s),grains.options,'UniformOutput',false);
  
  D = double(diag(any(grains.I_DG,2)));
  
  grains.A_D = grains.A_D*D;
  grains.I_FDext = grains.I_FDext*D;
  grains.I_FDsub = grains.I_FDsub*D;
  
  ebsd_subs = nonzeros(cumsum(old_D) .* any(grains.I_DG,2));
  
  grains.EBSD = grains.EBSD(ebsd_subs);
  
  D = any(grains.I_FDext | grains.I_FDsub,2);
  grains.F(~D,:) = 0;
  
  [i,j,v] = find(double(grains.F));
  D = sparse(v,1,1,size(grains.V,1),1)>0;
  grains.V(~D,:) = 0;
  
  
elseif strcmp(s.type,'()')
  
  ind = subsind(grains,s.subs);
  grains = subsref(grains,ind);
  
end





