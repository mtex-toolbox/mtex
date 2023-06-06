function varargout = subsref(gB,s)
% implements gB(1:10)
%
% Syntax
%   gB(1:10)                    % the 10 first boundaries
%   gB(cond)        
%
% Input
%  gB - @grain3Boundary
%  cond - logical array with same size as gB
%

if strcmp(s(1).type,'()')

  assert(length(s(1).subs)==1,'indexing only in one dimension possible')
  gB=subSet(gB,s(1).subs{1});
  
  % is there something more to do?
  if numel(s)>1
    s = s(2:end);
  else
    varargout{1} = gB;
    return
  end
end

% maybe reference to a dynamic property
%{
if isProperty(gB,s(1).subs)
  
  [varargout{1:nargout}] = subsref@dynProp(gB,s);
  
else
%}  
  [varargout{1:nargout}] = builtin('subsref',gB,s);
  
%end

end
