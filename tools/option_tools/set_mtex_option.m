function set_mtex_option(varargin)
% set mtex option

mtex_options = getappdata(0,'mtex_options');
if isempty(mtex_options), mtex_options={};end

mtex_options = set_option(mtex_options,varargin{:});
setappdata(0,'mtex_options',mtex_options);
