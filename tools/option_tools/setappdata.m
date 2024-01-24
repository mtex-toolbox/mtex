function varargout = setappdata(ax,varargin)
% make setappdata work with multiple handles

% Save multiple data2beDisplayed
persistent iter

if check_option(varargin,'data2beDisplayed')
  if isempty(iter) || iter>=10
    iter = 0;
  end
  iter = iter + 1;

  s = sprintf('data2beDisplayed_%d',iter);

  for a = ax(:).'
    varargout{1} = s;
    [varargout{2:nargout}] = builtin('setappdata',a,s,varargin{2:end});     
  end

  return
end

for a = ax(:).'
  [varargout{1:nargout}] = builtin('setappdata',a,varargin{:}); 
end
