function pos = find_option(option_list,option,type)
% find postions of the options in option_list
%
% Input
%  option_list - Cell Array
%  options     - String or Cell Array
%
% Output
%  pos         - doule


if ischar(option)
  found = strcmpi(option_list,option);
else
  found = false(size(option_list));
  for k=1:length(option)
    found = found | strcmpi(option{k},option_list);
  end
end
pos = find(found);

% option value required ?
if ~isempty(pos) && nargin > 2 
  
  % last option can not have an value
  if pos(end) == length(option_list), pos = pos(1:end-1);end
  
  % check type for all found options
  for p = length(pos):-1:1
    if isempty(type) || any(strcmpi(class(option_list{pos(p)+1}),type))
      pos = pos(p)+1;
      return
    else
      pos(p) = 0;
    end
  end
end

% no option required
if isempty(pos), pos = 0;else, pos = pos(end);end

%cellfun(@(c) ((ischar(c) || iscellstr(c)) && ...
%  any(strcmpi(c,{'PLAIN','antipodal'}))),varargin)
