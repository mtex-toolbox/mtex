function out = check_option(option_list,option,varargin)
% check for option in option list
%
% Syntax
%   out = check_option(option_list,option)
%   out = check_option(option_list,option,type)
%   out = check_option(option_list,option,[],value)
%
% Input
%  option_list - cell array
%  option      - option name, string or cell array of alias names
%  type        - class name or cell array of class names, the option value
%                is required to be of this class
%  value       - string the option value is required to be equal to
%
% Output
%  out         - true / false
%
% See also
% get_option set_option find_option delete_option

if isempty(option_list)
  out = false;
elseif nargin == 2  

  option_list = convertContainedStringsToChars(option_list);

  if iscell(option)
    out = any(cellfun(@(opt) any(strcmpi(option_list,opt)),option));
  else
    out = any(strcmpi(option_list,option));
  end

elseif nargin == 3

  out = find_option(option_list,option,varargin{:}) > 0;

else
  pos = find_option(option_list,option);
  out = pos > 0 && numel(option_list)>pos && ischar(option_list{pos+1}) && ...
    strcmpi(option_list{pos+1},varargin{2});
end
