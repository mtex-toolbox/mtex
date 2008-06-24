function set_mtex_option(varargin)
% get mtex option

global mtex_options;
if isempty(mtex_options), mtex_options={};end

mtex_options = set_option(mtex_options,varargin{:});
