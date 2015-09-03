function varargout = mtexColorbar(varargin)
% overide buildin Matlab colorbar function

if isappdata(gcf,'mtexFig')
  [varargout{1:nargout}] = colorbar(gcm,varargin{:});
else
  [varargout{1:nargout}] = colorbar(varargin{:});
end
