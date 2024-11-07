function varargout = setAllAppdata(ax,varargin)
% make setappdata work with multiple handles
%
% Syntax
%   setAllAppdata(ax,'name',value)
%
% Input
%  ax - axes handle
%  value - 
%

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

for k = 1:2:length(varargin)
  for a = ax(:).'
    setappdata(a,varargin{k:k+1});
  end
end
