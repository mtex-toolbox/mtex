function o = get_mtex_option(varargin)
% get mtex option

global mtex_options;
o = get_option(mtex_options,varargin{:});
