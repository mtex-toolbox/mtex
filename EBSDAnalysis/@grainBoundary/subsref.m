function varargout = subsref(gB,s)
% implements gB(1:10)
%
% Syntax
%   gB(1:10)                    % the 10 first boundaries
%   gB('Forsterite','Epidote')  % only Forsterite - Epidote boundaries
%   gB(cond)        
%
% Input
%  gB - @grainBoundary
%  cond - logical array with same size as gB
%

if strcmp(s(1).type,'()')
  
  ind = subsind(gB,s(1).subs);
  gB = subSet(gB,ind);

  % change the order of boundary
  phId = find(cellfun(@ischar,s(1).subs),1);
  
  if ~isempty(phId) && ~strcmpi(s(1).subs{phId},'indexed')
    
    phId = gB.name2id(s(1).subs{phId});
    
    % if a phase is specified flip boundaries such that the phase becomes first
    if ~ischar(gB.CSList{phId})
      gB = flip(gB,gB.phaseId(:,1) ~= phId);
    end
  end
    
  % is there something more to do?
  if numel(s)>1
    s = s(2:end);
  else
    varargout{1} = gB;
    return
  end
end

% maybe reference to a dynamic property
if isProperty(gB,s(1).subs)
  
  [varargout{1:nargout}] = subsref@dynProp(gB,s);
  
else
  
  [varargout{1:nargout}] = builtin('subsref',gB,s);
  
end

end
