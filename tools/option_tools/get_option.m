function value = get_option(option_list,option,default,type)
% extract option from option list
%
% In case the option occurs more than one time in the option list the first
% value that meets the type condition is returned.
%
% Syntax
%   value = get_option(option_list,option_name,default_option,option_type)
%
% Input
%  option_list   - Cell Array
%  option_name   - String
%  option_default- default value
%  option_type   - class name or list of class names
% Output
%  value         - option value
%
% See also
% check_option set_option delete_option

if nargin <= 2, value = [];else, value = default;end
if isempty(option_list), return;end
if nargin <= 3, type = [];end

pos = find_option(option_list,option,type);

if pos, value = option_list{pos};end
