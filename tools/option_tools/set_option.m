function out_list = set_option(option_list,option,varargin)
% set option in option list
%
%% Syntax
%  value = set_option(option_list,option,value) - 
%  value = set_option(option_list,{option1,option2,option3}) -
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
% check_option get_option delete_option

% delete previous options

if ~isempty(option)>0
  if iscellstr(varargin)
    option_list = delete_option(option_list,option,length(varargin));
  else
    option_list = delete_option(option_list,option);
  end

  % set option
  if ~iscell(option), option = {option};end
  out_list = [option_list,option,varargin];
else
  out_list = option_list;
end
