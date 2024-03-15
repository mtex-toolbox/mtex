function varargout = subsref(grains3,s)
% implements grains(1:3)
%
% Syntax
%   grains(1:10)            % the 10 first grains
%   grains('id',5)          % give the grain with id 5 
%   grains(cond)        
%
% Input
%  grains - @grain2d
%  cond   - logical array with same size as grains
%
if strcmp(s(1).type,'()') || strcmp(s(1).type,'{}')
  
  if strcmp(s(1).type,'{}')
    ind = grains3.id2ind(s(1).subs{1});
  else
    ind = subsind(grains3,s(1).subs);
  end
  
  
  grains3 = subSet(grains3,ind);
 
  % is there something more to do?
  if numel(s)>1
    s = s(2:end);
  else
    varargout{1} = grains3;
    return
  end
end

% maybe reference to a dynamic property
if isProperty(grains3,s(1).subs)
  
  [varargout{1:nargout}] = subsref@dynProp(grains3,s);
  
else

  [varargout{1:nargout}] = builtin('subsref',grains3,s);
  
end

end