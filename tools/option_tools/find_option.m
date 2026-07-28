function pos = find_option(option_list,option,type)
% find the last position of an option in an option_list
%
% If |type| is given the position of the option *value*, i.e. the entry
% following the option name, is returned - provided it exists and is of the
% requested class. Use |type = []| to accept any class.
%
% Syntax
%   pos = find_option(option_list,option)
%   pos = find_option(option_list,option,type)
%
% Input
%  option_list - cell array
%  option      - option name, string or cell array of alias names
%  type        - class name or cell array of class names
%
% Output
%  pos         - position of the option / its value, zero if not found
%
% See also
% get_option check_option set_option delete_option

option_list = convertContainedStringsToChars(option_list);

if iscell(option) % check for multiple options

  found = false(size(option_list));
  for k = 1:length(option)
    found = found | strcmpi(option_list,option{k});
  end
 
else % check for a single option
  found = strcmpi(option_list,option);
end

if ~any(found)
  
  pos = 0;

else

  pos = find(found,1,"last");

  if nargin > 2 % option value required

    % ensure we have the correct type
    if pos < length(option_list) && ... we need space for the option to check
      ~(ischar(type) && ~isa(option_list{pos+1},type)) && ... single class provided
      ~(iscell(type) && ~any(cellfun(@(x) isa(option_list{pos+1},x),type))) % multiple classes

      pos = pos + 1; % return next position
    else
      pos = 0;
    end
  end
end
