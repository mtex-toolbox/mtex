function varargout = subsref(grains,s)
% access subsets of a GrainSet
%
% Syntax
%   grains(1:10)          % the 10 first grains of a GrainSet
%   grains('Fe')          % only Fe grains
%   grains( ~grains('fe') ) % all grains but Fe
%                           logical array with size of the complete
%                           GrainSet

if strcmp(s(1).type,'()')
  
  ind = subsind(grains,s(1).subs);
  grains = subSet(grains,ind);
 
  % is there something more to do?
  if numel(s)>1
    s = s(2:end);
  else
    varargout{1} = grains;
    return
  end
end

% maybe reference to a dynamic property
if isProperty(grains,s(1).subs)
  
  [varargout{1:nargout}] = subsref@dynProp(grains,s);
  
else
  
  [varargout{1:nargout}] = builtin('subsref',grains,s);
  
end

end
