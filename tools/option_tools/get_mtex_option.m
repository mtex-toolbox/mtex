function o = get_mtex_option(varargin)
% get mtex option

mtex_options = getappdata(0,'mtex_options');
o = get_option(mtex_options,varargin{:});
