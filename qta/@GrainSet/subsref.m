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
  varargout{1} = subSet(grains,ind);
  
elseif strcmp(s(1).type,'.')
  
  % maybe reference to a dynamic option
  %try %#ok<TRYNC>
  %  [varargout{1:nargout}] = subsref@dynOption(grains,s);
  %  return
  %end
  
  % maybe reference to a dynamic property
  try %#ok<TRYNC>
    [varargout{1:nargout}] = subsref@dynProp(grains,s);
    return
  end
  
  % maybe reference to a normal property
  [varargout{1:nargout}] = builtin('subsref',grains,s);
  
end

% is there something more to do?
if numel(s)>1
  varargout{1} = subsref(varargout{1},s(2:end));
  return
end

