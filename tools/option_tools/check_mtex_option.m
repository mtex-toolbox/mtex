function o = check_mtex_option(varargin)
% get mtex option

global mtex_options;
o = check_option(mtex_options,varargin{:});
