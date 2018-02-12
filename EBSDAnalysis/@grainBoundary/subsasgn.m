function gB = subsasgn(gB,s,b)
% overloads subsasgn

if ~isa(gB,'grainBoundary'), gB = b([]); end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  subsasgn(subsref(gB,s(1)),s(2:end),b); end

    s(1).subs = {subsind(gB,s(1).subs)};
        
    if isempty(b)
      
      if islogical(s(1).subs{1})
        s(1).subs = {~s(1).subs{1}};
      else
        id = true(size(gB));
        id(s(1).subs{1}) = false;
        s(1).subs = {id};
      end
      gB = subsref(gB,s(1));      
      
    else
      
      gB = subsasgn@dynProp(gB,s(1),b);
      gB.misrotation = subsasgn(gB.misrotation,s(1),b.misrotation);
      
      id1 = subsasgn(gB.grainId(:,1),s(1),b.grainId(:,1));
      id2 = subsasgn(gB.grainId(:,2),s(1),b.grainId(:,2));      
      gB.grainId = [id1(:),id2(:)];
      
      id1 = subsasgn(gB.phaseId(:,1),s(1),b.phaseId(:,1));
      id2 = subsasgn(gB.phaseId(:,2),s(1),b.phaseId(:,2));      
      gB.phaseId = [id1(:),id2(:)];
      
      id1 = subsasgn(gB.F(:,1),s(1),b.F(:,1));
      id2 = subsasgn(gB.F(:,2),s(1),b.F(:,2));      
      gB.F = [id1(:),id2(:)];
      
      gB.V = b.V;      
      gB.CSList = b.CSList;
      gB.phaseMap = b.phaseMap;

    end
    
  otherwise
        
    if gB.isProperty(s(1).subs) % otherwise a property
      
      gB = subsasgn@dynProp(gB,s,b);
      
    else
      
      gB = builtin('subsasgn',gB,s,b);
      
    end

end
end
