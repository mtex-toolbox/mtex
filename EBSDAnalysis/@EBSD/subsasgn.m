function ebsd = subsasgn(ebsd,s,b)
% overloads subsasgn
%
% Syntax
%
%   ebsd(1:5).phaseId = 2
%   ebsd{2}.CS = crystalSymmetry('m-3m')
%


if strcmp(s(1).type,'{}')
  s(1).type = '()';
  s(1).subs{1} = ebsd.id2ind(s(1).subs{1});
  ebsd = subsasgn(ebsd,s,b);
  return
end

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
      ebsd.id = subsasgn(ebsd.id,s(1),[]);
      ebsd.phaseId = subsasgn(ebsd.phaseId,s(1),[]);      
      
      ebsd = EBSD(ebsd);
      
    elseif ischar(b)
      
      phId = find(strcmpi(b,ebsd.mineralList),1);
      ebsd.phaseId = subsasgn(ebsd.phaseId,s(1),phId);
      
    elseif isnumeric(b) && isnan(b)
      
      ebsd.rotations = subsasgn(ebsd.rotations,s(1),nan);
      ebsd.phaseId = subsasgn(ebsd.phaseId,s(1),nan);
                  
    else
      
      ebsd = subsasgn@dynProp(ebsd,s(1),b);
      ebsd.rotations = subsasgn(ebsd.rotations,s(1),b.rotations);
      ebsd.id = subsasgn(ebsd.id,s(1),b.id);
      ebsd.phaseId = subsasgn(ebsd.phaseId,s(1),b.phaseId);
      ebsd.CSList = b.CSList;
      ebsd.phaseMap = b.phaseMap;
      
    end
    
  otherwise
        
    if ebsd.isOption(s(1).subs) % maybe it is an option
      
      ebsd = subsasgn@dynOption(ebsd,s,b);
      
    elseif ebsd.isProperty(s(1).subs) % otherwise a property
      
      ebsd = subsasgn@dynProp(ebsd,s,b);
      
      % maybe we should update the unit cell
      if any(strcmp(s(1).subs,{'x','y'}))
        ebsd = ebsd.updateUnitCell;
      end
      
    else
      
      ebsd = builtin('subsasgn',ebsd,s,b);
      
    end

end
end
