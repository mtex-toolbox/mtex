function tP = subsasgn(tP,s,b)
% overloads subsasgn

if ~isa(tP,'triplePointList'), tP = b([]); end

switch s(1).type
  
  case '()'
      
    if numel(s)>1, b =  subsasgn(subsref(tP,s(1)),s(2:end),b); end

    s(1).subs = {subsind(tP,s(1).subs)};
        
    if isempty(b)
      
      s(1).subs = {~s(1).subs{1}};
      tP = subsref(tP,s(1));      
      
    else
      
      tP = subsasgn@dynProp(tP,s(1),b);
      tP.misrotation = subsasgn(tP.misrotation,s(1),b.misrotation);
      
      id1 = subsasgn(tP.grainId(:,1),s(1),b.grainId(:,1));
      id2 = subsasgn(tP.grainId(:,2),s(1),b.grainId(:,2));      
      tP.grainId = [id1(:),id2(:)];
      
      id1 = subsasgn(tP.phaseId(:,1),s(1),b.phaseId(:,1));
      id2 = subsasgn(tP.phaseId(:,2),s(1),b.phaseId(:,2));      
      tP.phaseId = [id1(:),id2(:)];
      
      id1 = subsasgn(tP.F(:,1),s(1),b.F(:,1));
      id2 = subsasgn(tP.F(:,2),s(1),b.F(:,2));      
      tP.F = [id1(:),id2(:)];
      
      tP.V = b.V;      
      tP.CSList = b.CSList;
      tP.phaseMap = b.phaseMap;

    end
    
  otherwise
        
    if tP.isProperty(s(1).subs) % otherwise a property
      
      tP = subsasgn@dynProp(tP,s,b);
      
    else
      
      tP = builtin('subsasgn',tP,s,b);
      
    end

end
end
