function varargout = buildinColorbar(varargin)

s = which('colorbar','-all');
pathstr = fileparts(s{end});
opwd = pwd;
cd(pathstr);
    
[varargout{1:nargout}] = colorbar(varargin{:});

cd(opwd);
