function varargout = subsref(gB3,s)
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

  subs=s(1).subs;
  
  assert(length(subs)==1&& (isnumeric(subs{1}) || islogical(subs{1}))...
    , 'indexing only supported for numerical or logical values')
  
  gB3=subSet(gB3,subs{1});
  
  % is there something more to do?
  if numel(s)>1
    s = s(2:end);
  else
    varargout{1} = gB3;
    return
  end
end

% maybe reference to a dynamic property
if isProperty(gB3,s(1).subs)
  
  [varargout{1:nargout}] = subsref@dynProp(gB3,s);
  
else

  [varargout{1:nargout}] = builtin('subsref',gB3,s);
  
end

end
