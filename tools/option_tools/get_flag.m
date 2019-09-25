function flag = get_flag(option_list,flag_list,default)
% extract flag from option list
%
% In case the option occurs more than one time in the option list the first
% value that meets the type condition is returned.
%
% Syntax
%   flag = get_flag(option_list,flag_list,default_flag)
%
% Input
%  option_list  - Cell Array
%  flag_list    - Cell Array
%  default_flag - default value
%
% Output
%  flag         - string
%
% See also
% check_option set_option delete_option

if nargin <= 2, flag = [];else flag = default;end

pos = find_option(option_list,flag_list);

if pos, flag = option_list{pos};end
