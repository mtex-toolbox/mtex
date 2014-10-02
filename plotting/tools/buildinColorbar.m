function varargout = buildinColorbar(varargin)
% overide buildin Matlab colorbar function

% locate default colorbar
s = which('colorbar','-all');
pathstr = fileparts(s{end});
opwd = pwd;
cd(pathstr);
[varargout{1:nargout}] = colorbar(varargin{:});
cd(opwd);
