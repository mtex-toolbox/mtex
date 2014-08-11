function ebsd = subsasgn(ebsd,s,b)
% overloads subsasgn

if ~isa(ebsd,'EBSD')
  ebsd = EBSD;
  ebsd.CSList = b.CSList;
end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  subsasgn(subsref(ebsd,s(1)),s(2:end),b); end

    s(1).subs = {subsind(ebsd,s(1).subs)};
        
    if isempty(b)
      
      ebsd = subsasgn@dynProp(ebsd,s(1),[]);
      ebsd.rotations = subsasgn(ebsd.rotations,s(1),[]);
                  
    else
      
      ebsd = subsasgn@dynProp(ebsd,s(1),b);
      ebsd.rotations = subsasgn(ebsd.rotations,s(1),b.rotations);
      ebsd.CSList = b.CSList;
      ebsd.phaseMap = b.phaseMap;
      
    end
    
  otherwise
        
    if ebsd.isOption(s(1).subs) % maybe it is an option
      
      ebsd = subsasgn@dynOption(ebsd,s,b);
      
    elseif ebsd.isProperty(s(1).subs) % otherwise a property
      
      ebsd = subsasgn@dynProp(ebsd,s,b);
      
    else
      
      ebsd = builtin('subsasgn',ebsd,s,b);
      
    end

end
end
