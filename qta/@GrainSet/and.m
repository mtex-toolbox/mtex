function a = and(grains,expr)



if isa(grains,'GrainSet')
  grains = full(any(grains.I_DG,1));
end

if isa(expr,'GrainSet')
  expr = full(any(expr.I_DG,1));  
end

a = grains(:) & expr(:);