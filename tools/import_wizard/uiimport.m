function uiimport(varargin)
% overload standard MATLAB uiimport

if nargin && ischar(varargin{1})
  [pathstr, name, ext] = fileparts(varargin{1});
  if any(strcmpi(get_mtex_option('polefigure_ext',{},'cell'),ext))
    import_wizard('PoleFigure',varargin{:});
  elseif any(strcmpi(get_mtex_option('EBSD_ext',{},'cell'),ext))
    import_wizard('EBSD',varargin{:});      
  else
    old_uiimport(varargin{:});      
  end
else
  old_uiimport(varargin{:});
end

function old_uiimport(varargin)

s = which('uiimport','-all');
pathstr = fileparts(s{end});
opwd = pwd;
cd(pathstr);
uiimport(varargin{:});
cd(opwd);


