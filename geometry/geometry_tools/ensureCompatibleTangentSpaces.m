function tS = ensureCompatibleTangentSpaces(v1,v2)

tS1 = [];
tS2 = [];

if isa(v1,'SO3TangentVector')
  tS1 = v1.tangentSpace;
end
if isa(v2,'SO3TangentVector')
  tS2 = v2.tangentSpace;
end
if isa(v1,'SO3VectorField')
  tS1 = v1.tangentSpace;
end
if isa(v2,'SO3VectorField')
  tS2 = v2.tangentSpace;
end
  
if  ~isempty(tS1) && ~isempty(tS2) && ~strcmp(tS1,tS2)
    error('You are mixing left and right sided representation of the tangent spaces.')
end

if nargout<1
  return
end

if isempty([tS1,tS2])
  tS = [];
elseif isempty(tS1)
  tS = tS2;
else
  tS = tS1;
end


end