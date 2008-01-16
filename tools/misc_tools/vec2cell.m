function c = vec2cell(v)

if iscell(v)
  c = v;
else
  c = mat2cell(v,ones(1,size(v,1)),ones(1,size(v,2)));
end
