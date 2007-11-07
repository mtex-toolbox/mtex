function out_list = set_default_option(option_list,option,varargin)
% set option in option list if not yet present
%
%% Syntax
%  value = set_option(option_list,option,value)
%  value = set_option(option_list,{option1,option2,option3})
%
%% Input
%  option_list   - Cell Array
%  option        - String
%  value         - some type
%
%% Output
%  out_list      - Cell Array
%
%% See also
% check_option get_option clear_option

if ~check_option(option_list,option)
  out_list = set_option(option_list,option,varargin);
end

