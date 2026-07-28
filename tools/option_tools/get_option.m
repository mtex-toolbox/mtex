function value = get_option(option_list,option,default,type)
% extract option from option list
%
% In case the option occurs more than one time in the option list the last
% occurrence is used. If its value does not match |type| the default is
% returned.
%
% Syntax
%   value = get_option(option_list,option,default,type)
%
% Input
%  option_list - cell array
%  option      - option name, string or cell array of alias names
%  default     - value returned if the option is not found
%  type        - class name or cell array of class names
%
% Output
%  value       - option value
%
% See also
% check_option set_option delete_option

if nargin <= 2, value = [];else, value = default; end
if isempty(option_list), return; end
if nargin <= 3, type = []; end

pos = find_option(option_list,option,type);

if pos, value = option_list{pos};end
