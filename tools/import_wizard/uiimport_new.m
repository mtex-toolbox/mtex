function uiimport(varargin)

global mtex_ext_polefigures;
global mtex_ext_ebsd;

if nargin && ischar(varargin{1})
  [pathstr, name, ext, versn] = fileparts(varargin{1});
  if any(strcmp(mtex_ext_polefigures,ext))
    import_wizard(varargin{:});
  elseif any(strcmp(mtex_ext_ebsd,ext))
    import_wizard_EBSD(varargin{:});      
  else
    old_uiimport(varargin{:});      
  end
else
  old_uiimport(varargin{:});
end

function old_uiimport(varargin)

addpath([matlabroot '/toolbox/matlab/codetools']);
feval('uiimport',varargin{:});
rmpath([matlabroot '/toolbox/matlab/codetools']);
addpath([matlabroot '/toolbox/matlab/codetools'],0);
