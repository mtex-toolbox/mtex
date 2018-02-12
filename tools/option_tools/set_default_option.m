function out_list = set_default_option(option_list,preserve,option,varargin)
% set option in option list if not yet present
%
% Syntax
%   value = set_default_option(option_list,preserve,option,value) -
%   value = set_default_option(option_list,preserve,{option1,option2,option3}) -
%
% Input
%  option_list   - Cell Array
%  preserve      - options to be preserved
%  option        - String
%  value         - some type
%
% Output
%  out_list      - Cell Array
%
% See also
% check_option get_option delete_option

if nargin == 2
  out_list = [preserve,option_list];
  return
end

if ~check_option(option_list,union_cell(ensure_cell(option),ensure_cell(preserve)))
  out_list = set_option(option_list,option,varargin{:});
else 
  out_list = option_list;
end

function c = ensure_cell(s)

if isempty(s)
  c = {};
elseif isa(s,'cell')
  c = s;
else
  c = {s};
end

function c = union_cell(varargin)

c = {};
for i = 1:length(varargin)
  c = [c,varargin{i}];
end
