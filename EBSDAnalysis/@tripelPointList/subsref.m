function varargout = subsref(gB,s)
% access subsets of a GrainSet
%
% Syntax
%   gB(1:10)               % the 10 first boundaries
%   gB('Forsterite','Epidote')  % only Forsterite - Epidote boundaries
%   grains( ~grains('fe') ) % all grains but Fe
%                           logical array with size of the complete
%                           GrainSet

if strcmp(s(1).type,'()')
  
  ind = subsind(gB,s(1).subs);
  gB = subSet(gB,ind);
 
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
