function grains = subsasgn(grains,s,b)
% overloads subsasgn

if ~isa(grains,'grain2d'), grains = b([]); end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  subsasgn(subsref(grains,s(1)),s(2:end),b); end

    s(1).subs = {subsind(grains,s(1).subs)};
        
    if isempty(b)
      
      if islogical(s(1).subs{1})
        s(1).subs = {~s(1).subs{1}};
      else
        ind = true(size(grains));
        ind(s(1).subs{1}) = false;
        s(1).subs = {ind};
      end
      
      grains = subsref(grains,s(1));      
      
    else
      
      grains = subsasgn@dynProp(grains,s(1),b);
      grains.id = subsasgn(grains.id,s(1),b.id);
      grains.phaseId = subsasgn(grains.phaseId,s(1),b.phaseId);
      grains.grainSize = subsasgn(grains.grainSize,s(1),b.grainSize);
      grains.poly = subsasgn(grains.poly,s(1),b.poly);
      grains.inclusionId = subsasgn(grains.inclusionId,s(1),b.inclusionId);
      grains.CSList = b.CSList;
      grains.boundary.CSList = b.CSList;
      grains.innerBoundary.CSList = b.CSList;
      grains.triplePoints.CSList = b.CSList;
      grains.phaseMap = b.phaseMap;
      grains.boundary.phaseMap = b.phaseMap;
      grains.innerBoundary.phaseMap = b.phaseMap;
      grains.triplePoints.phaseMap = b.phaseMap;

    end
    
  otherwise
        
    if grains.isProperty(s(1).subs) % otherwise a property
      
      grains = subsasgn@dynProp(grains,s,b);
      
    else
      
      grains = builtin('subsasgn',grains,s,b);
      
    end

end
end
