function v = subsasgn(v,s,b)
% overloads subsasgn

if ~isa(v,'vector3d') && ~isempty(b)
  v = b;
  v.x = [];
  v.y = [];
  v.z = [];
end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  builtin('subsasgn',subsref(v,s(1)),s(2:end),b); end
      
    if isnumeric(b)
      v.x = subsasgn(v.x,s(1),b);
      v.y = subsasgn(v.y,s(1),b);
      v.z = subsasgn(v.z,s(1),b);
      v.isNormalized = false;
    else
      v.x = subsasgn(v.x,s(1),b.x);
      v.y = subsasgn(v.y,s(1),b.y);
      v.z = subsasgn(v.z,s(1),b.z);
      v.isNormalized = v.isNormalized & b.isNormalized;
    end
  otherwise
    
    v =  builtin('subsasgn',v,s,b);
    
    % ensure x,y,z have the same size
    if isscalar(v.x), v.x = repmat(v.x,size(v.y));end
    if isscalar(v.y), v.y = repmat(v.y,size(v.z));end
    if isscalar(v.z), v.z = repmat(v.z,size(v.x));end   
end

end
