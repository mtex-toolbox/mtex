function varargout = mtexColorbar(varargin)
% overide buildin Matlab colorbar function
%
% Syntax
%   % add a colorbar with title
%   mtexColorbar('title','misorientation angle')
%
%   % add a colorbar vertical colorbar
%   mtexColorbar('location','eastoutside')
%
%   % add a horizontal colorbar
%   mtexColorbar('location','southoutside')
%
%   % add one colorbar for all sub figures
%   setColorRange('equal') % set equal color range for all subplots
%   mtexColorbar % add the color bar
%  
%   % add individual colorbars for all sub figures
%   mtexColorbar('multiple')
%

if isappdata(gcf,'mtexFig')
  [varargout{1:nargout}] = colorbar(gcm,varargin{:});
else
  [varargout{1:nargout}] = colorbar(varargin{:});
end
