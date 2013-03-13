function [ax,varargout] = getAxHandle(varargin)
% seperate axis handle from input

% extract axes handle
if all(ishandle(varargin{1})) && strcmp(get(varargin{1}(1),'type'),'axes')
  ax = varargin(1); 
  varargin(1) = [];
else
  ax = {};
end

% set output
varargout(1:nargout-2) = varargin(1:nargout-2);
varargout{nargout-1} = varargin(nargout-1:end);
  


