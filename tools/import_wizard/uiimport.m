function uiimport(varargin)

global mtex_ext_polefigures;
global mtex_ext_ebsd;

if nargin && ischar(varargin{1})
  [pathstr, name, ext] = fileparts(varargin{1});
  if any(strcmp(mtex_ext_polefigures,ext))
    import_wizard_PoleFigure('file',varargin{:});
  elseif any(strcmp(mtex_ext_ebsd,ext))
    import_wizard_EBSD('file',varargin{:});      
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


