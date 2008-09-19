function out = check_option(option_list,option,varargin)
% check for option in option list
%
%% Syntax
% out = check_option(option_list,option_name,type)
% out = check_option(option_list,option_name,[],option)
%
%% Input
%  option_list - Cell Array
%  option_name - String
%  option      - String
%  type        - class
%
%% Output
%  out         - true / false
%
%% See also
% get_option set_option clear_option find_option

if isempty_cell(option_list)
  out = false;
elseif nargin <= 3
  out = find_option(option_list,option,varargin{:}) > 0;
else
  pos = find_option(option_list,option,'char');
  out = pos > 0 && any(strcmpi(option_list{pos},varargin{2}));
end
