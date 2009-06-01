function gr = setproperty(gr,vname,prop)

if numel(prop) == numel(gr)
  for k=1:numel(gr)
    gr(k).properties.(vname) = prop(k);
  end
else
  error('dimension missmatch')
end
