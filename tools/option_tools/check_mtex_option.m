function o = check_mtex_option(varargin)
% get mtex option

mtex_options = getappdata(0,'mtex_options');
o = check_option(mtex_options,varargin{:});
