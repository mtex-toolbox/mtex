function v = subsasgn(v,s,b)
% overloads subsasgn

if isempty(v) && ~isempty(b)
  v = b;
  v.x = [];
  v.y = [];
  v.z = [];
end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  builtin('subsasgn',subsref(v,s(1)),s(2:end),b); end
      
    if isempty(b)
      v.x = subsasgn(v.x,s(1),[]);
      v.y = subsasgn(v.y,s(1),[]);
      v.z = subsasgn(v.z,s(1),[]);
    else
      v.x = subsasgn(v.x,s(1),b.x);
      v.y = subsasgn(v.y,s(1),b.y);
      v.z = subsasgn(v.z,s(1),b.z);
    end
  otherwise
    
    v =  builtin('subsasgn',v,s,b);    
      
end

end
