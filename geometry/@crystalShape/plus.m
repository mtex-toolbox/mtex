function cS = plus(cS,v)

% crystal shape should be first argument
if ~isa(cS,'crystalShape'), [cS,v] = deal(v,cS); end

% shift should be vector3d
if isa(v,'double')  
  if size(v,2)==2, v = [v,ones(size(v,1),1)]; end
  v = vector3d(v.');
else
  v = v(:).';
end

% extent shift by number of vertices of the crystal
v = repmat(v,size(cS.V,1),1);

% extend the crystals by the number of shifts
if size(cS.V,2) == 1
  cS = repmat(cS,size(v,2));
end

% shift vertices
cS.V = cS.V + v;