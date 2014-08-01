function grains = subsasgn(grains,s,b)
% overloads subsasgn

if ~isa(grains,'GrainSet'), grains = b([]); end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  subsasgn(subsref(grains,s(1)),s(2:end),b); end

    s(1).subs = {subsind(grains,s(1).subs)};
        
    if isempty(b)
      
      s(1).subs = {~s(1).subs{1}};
      grains = subsref(grains,s(1));      
                  
    else
      
      grains = subsasgn@dynProp(grains,s(1),b);
      grains.meanRotation = subsasgn(grains.meanRotation,s(1),b.meanRotation);
      grains.allCS = b.allCS;
      grains.phaseMap = b.phaseMap;
      
    end
    
  otherwise
        
    if grains.isProperty(s(1).subs) % otherwise a property
      
      grains = subsasgn@dynProp(grains,s,b);
      
    else
      
      grains = builtin('subsasgn',grains,s,b);
      
    end

end
end
