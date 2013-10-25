function varargout = subsref(ebsd,s)
% indexing of EBSD data
%
% Syntax
%   ebsd('Fe')        - returns data of phase Fe
%   ebsd({'Fe','Mg'}) - returns data of phase Fe and Mg
%   ebsd(1:end)       - returns data 
%

% called with direct indexing
if isa(s,'double') || isa(s,'logical')
    
  varargout{1} = subsref@dynProp(ebsd,s);
  varargout{1}.rotations = ebsd.rotations(s);
  return;
  
end
  
if strcmp(s(1).type,'()')
  
  if check_option(s(1).subs,'sort')
    
    ebsd = subsref(ebsd,get_option(s(1).subs,'sort'));
    
  else
    
    ind = subsind(ebsd,s(1).subs);
    ebsd = subsref(ebsd,ind);
    
  end

  % is there something more to do?
  if numel(s)>1
    s = s(2:end);
  else
    varargout{1} = ebsd;
    return
  end  

end

% maybe reference to a dynamic option
try %#ok<TRYNC>
  [varargout{1:nargout}] = subsref@dynOption(ebsd,s);
  return
end
  
% maybe reference to a dynamic property
try %#ok<TRYNC>
  [varargout{1:nargout}] = subsref@dynProp(ebsd,s);
  return
end
  
% maybe reference to a normal property
[varargout{1:nargout}] = builtin('subsref',ebsd,s);

end
