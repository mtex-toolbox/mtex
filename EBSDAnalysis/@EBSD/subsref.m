function varargout = subsref(ebsd,s)
% indexing of EBSD data
%
% Syntax
%   ebsd('Fe')        - returns data of phase Fe
%   ebsd({'Fe','Mg'}) - returns data of phase Fe and Mg
%   ebsd(1:end)       - returns 
%


% some special cases to speed things up
if strcmp(s(1).type,'()') && ischar(s(1).subs{1}) && ...
    length(s)>1 && strcmp(s(2).type,'.') && strcmp(s(2).subs,'CS')
  
  id = ebsd.name2id(s(1).subs{1});
  if id ~= 0
    
    CS = ebsd.CSList{id}; 
    if numel(s)>2
      [varargout{1:nargout}] = builtin('subsref',CS,s(3:end));
    else
      varargout{1} = CS;
    end   
    return
  end
end

% now the general case
if strcmp(s(1).type,'()') || strcmp(s(1).type,'{}')
  
  if strcmp(s(1).type,'{}')
    ind = ebsd.id2ind(s(1).subs{1});
  else
    ind = subsind(ebsd,s(1).subs);
  end
  
  
  ebsd = subSet(ebsd,ind);
    
  % is there something more to do?
  if numel(s)>1
    s = s(2:end);
  else
    varargout{1} = ebsd;
    return
  end  

end

% maybe reference to a dynamic property
if isProperty(ebsd,s(1).subs) && ~any(strcmp(s(1).subs,{'mis2mean','grainId'}))
  
  [varargout{1:nargout}] = subsref@dynProp(ebsd,s);
  
else
  
  [varargout{1:nargout}] = builtin('subsref',ebsd,s);
  
end

end
