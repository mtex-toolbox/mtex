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

  if (length(subs)==2 && (subs{2} == "ind"))
    ind = subs{1};
    assert((isnumeric(ind) || islogical(ind))...
    , 'indexing only supported for numerical or logical values')
  elseif length(subs)==1
    if isnumeric(subs{1})
      id = subs{1};
    elseif islogical(subs{1})
      id = find(subs{1});
    else
      error 'indexing only supported for numerical or logical values'
    end
    ind = id2ind(gB3,id);
  else
    error 'error'
  end
  
  gB3=subSet(gB3,ind);
  
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
