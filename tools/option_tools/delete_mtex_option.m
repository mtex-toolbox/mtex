function delete_mtex_option(varargin)
% get mtex option

mtex_options = getappdata(0,'mtex_options');

if isempty(mtex_options) || nargin == 0
  mtex_options={};
else
  mtex_options = delete_option(mtex_options,varargin{:});
end

setappdata(0,'mtex_options',mtex_options);
