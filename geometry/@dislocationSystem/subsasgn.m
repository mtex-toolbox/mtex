function dS = subsasgn(dS,s,value)
% overloads subsasgn

if ~isa(dS,'dislocationSystem') && ~isempty(value)
  dS = value;
  dS.b.x = [];
  dS.b.y = [];
  dS.b.z = [];
  dS.l.x = [];  
  dS.l.y = [];  
  dS.l.z = [];
  dS.u = [];
end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, value =  builtin('subsasgn',subsref(dS,s(1)),s(2:end),value); end
      
    if isempty(value)
      dS.b = subsasgn(dS.b,s(1),[]);
      dS.l = subsasgn(dS.l,s(1),[]);
      dS.u = subsasgn(dS.u,s(1),[]);
    else
      dS.b = subsasgn(dS.b,s(1),value.b);
      dS.l = subsasgn(dS.l,s(1),value.l);
      dS.u = subsasgn(dS.u,s(1),value.u);
    end
  otherwise
    
    dS =  builtin('subsasgn',dS,s,value);    

end

end
