function option_list = set_option(option_list,option,varargin)
% set option in option list
%
% Previous occurrences of the option are removed, i.e. the option is set
% exactly once.
%
% Syntax
%   option_list = set_option(option_list,option,value)
%   option_list = set_option(option_list,{option1,option2,option3})
%
% Input
%  option_list - cell array
%  option      - option name, string or cell array of names to be set
%  value       - option value, any class, multiple values are allowed
%
% Output
%  option_list - cell array
%
% See also
% check_option get_option find_option delete_option

% delete previous options
option_list = delete_option(option_list,option,length(varargin));
  
% set option
if ~iscell(option), option = {option};end
option_list = [option_list,option,varargin];
