function import_wizard_PoleFigure( varargin )
% import helper for PoleFigure data
%

if nargin>0  && ischar(varargin{1}) && ~strcmp(varargin{1},'file') 
  feval(varargin{:});
else
  import_wizard('type','PoleFigure');
  if check_option(varargin,'file')
    [path,fn,ext] = fileparts(get_option(varargin,'file'));
    addfile({[fn,ext]}, [path,filesep]);
  end
end
