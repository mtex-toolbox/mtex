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

  subs = s(1).subs;
  
  % turn phaseNames into crystalSymmetry
  isCS = cellfun(@(x) ischar(x) | isstring(x) | isa(x,'crystalSymmetry'),subs);  
  phId = cellfun(@gB.name2id,subs(isCS));
  isCS(isCS) = phId>0; phId(phId==0) = [];
  subs(isCS) = gB.CSList(phId);
  
  % restrict to subset
  ind = subsind(gB,subs);
  gB = subSet(gB,ind);

  % if a phase is specified flip boundaries such that the phase becomes first
  if ~isempty(phId) && phId(1)>1
    gB = flip(gB,gB.phaseId(:,1) ~= phId(1));
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
