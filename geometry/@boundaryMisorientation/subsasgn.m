function bM = subsasgn(bM,s,b)
% overloads subsasgn

if isempty(bM) && ~isempty(b)
  bM = b;
  bM.mori = [];
  bM.N1 = [];
end

if islogical(s) || isnumeric(s)
  s = substruct('()',{s});
end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  builtin('subsasgn',subsref(bM,s(1)),s(2:end),b); end
      
    if isempty(b)
      bM.mori = subsasgn(bM.mori,s(1),[]);
      bM.N1 = subsasgn(bM.N1,s(1),[]);
    else
      bM.mori = subsasgn(bM.mori,s(1),b.a);
      bM.N1 = subsasgn(bM.N1,s(1),b.b);
    end
  otherwise
      
    bM =  builtin('subsasgn',bM,s,b);
      
end

end
