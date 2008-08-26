function out_list = set_option(option_list,option,varargin)
% set option in option list
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

% delete previous options

if ~isempty(option)>0
  option_list = delete_option(option_list,option,length(varargin));

  % set option
  if ~iscell(option), option = {option};end
  out_list = {option_list{:},option{:},varargin{:}};
else
  out_list = option_list;
end

