function delete_mtex_option(varargin)
% get mtex option

global mtex_options;

if isempty(mtex_options) || nargin == 0
  mtex_options={};
else
  mtex_options = delete_option(mtex_options,varargin{:});
end


