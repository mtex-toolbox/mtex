function out = check_option(option_list,option,varargin)
% check for option in option list
%
%% Syntax
% out = check_option(option_list,option,type)
%
%% Input
%  option_list - Cell Array
%  option      - String
%  type        - class
%
%% Output
%  out         - true / false
%
%% See also
% get_option set_option clear_option find_option

out = find_option(option_list,option,varargin{:}) > 0;
