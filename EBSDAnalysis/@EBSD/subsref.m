function varargout = subsref(ebsd,s)
% indexing of EBSD data
%
% Syntax
%   ebsd('Fe')        - returns data of phase Fe
%   ebsd({'Fe','Mg'}) - returns data of phase Fe and Mg
%   ebsd(1:end)       - returns data 
%

if strcmp(s(1).type,'()')
  
  ind = subsind(ebsd,s(1).subs);
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
if isProperty(ebsd,s(1).subs)
  
  [varargout{1:nargout}] = subsref@dynProp(ebsd,s);
  
else
  
  [varargout{1:nargout}] = builtin('subsref',ebsd,s);
  
end

end
