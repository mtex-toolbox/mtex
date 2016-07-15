function sS = subsasgn(sS,s,value)
% overloads subsasgn

if ~isa(sS,'slipSystem') && ~isempty(value)
  sS = value;
  sS.b.x = [];
  sS.b.y = [];
  sS.b.z = [];
  sS.n.x = [];  
  sS.n.y = [];  
  sS.n.z = [];
  sS.CRSS = [];
end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, value =  builtin('subsasgn',subsref(sS,s(1)),s(2:end),value); end
      
    if isempty(value)
      sS.b = subsasgn(sS.b,s(1),[]);
      sS.n = subsasgn(sS.n,s(1),[]);
      sS.CRSS = subsasgn(sS.CRSS,s(1),[]);
    else
      sS.b = subsasgn(sS.b,s(1),value.b);
      sS.n = subsasgn(sS.n,s(1),value.n);
      sS.CRSS = subsasgn(sS.CRSS,s(1),value.CRSS);
    end
  otherwise
    
    sS =  builtin('subsasgn',sS,s,value);    

end

end
