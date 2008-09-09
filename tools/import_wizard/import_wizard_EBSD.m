function import_wizard_EBSD( varargin )
% import helper for EBSD data
%

if nargin >0  && ischar(varargin{1}) && ~strcmp(varargin{1},'file') 
   feval(varargin{:});
else
  import_wizard('type','EBSD');
  if check_option(varargin,'file')
    [path,fn,ext] = fileparts(get_option(varargin,'file'));
    addfile({[fn,ext]}, [path,filesep]);
  end
end

