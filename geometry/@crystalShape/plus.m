function cS = plus(cS,v)

if ~isa(cS,'crystalShape')
  [cS,v] = deal(v,cS); 
end

if isa(v,'double')  
  if size(v,2)==2, v = [v,ones(size(v,1),1)]; end
  v = vector3d(v.');
else
  v = v(:).';
end

v = repmat(v,length(cS.V)/length(v),1);
cS.V = cS.V + reshape(v,size(cS.V));