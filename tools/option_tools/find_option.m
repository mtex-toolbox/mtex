function pos = find_option(option_list,option,type)
% find the latest position of an option in an option_list
%
% Input
%  option_list - Cell Array
%  options     - String or Cell Array
%  type        - list of allowed option classes
%
% Output
%  pos         - position of the option, zero if not found

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
