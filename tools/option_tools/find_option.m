function pos = find_option(option_list,option,type)
% find positions of the options in option_list
%
% Input
%  option_list - Cell Array
%  options     - String or Cell Array
%  type        - list of allowed option classes
%
% Output
%  pos         - double

if ischar(option)
  found = strcmpi(option_list,option);
else
  found = false(size(option_list));
  for k=1:length(option)
    found = found | strcmpi(option{k},option_list);
  end
end
pos = find(found);

if isempty(pos)
  
  pos = 0;

elseif nargin == 2 % not option value required

  pos = pos(end); % take the last occurence

else % option value required

  % last option can not have an value
  if pos(end) == length(option_list), pos(end) = [];end

  if isempty(pos)

    pos = 0;

  elseif isempty(type) % no specific type required
    
    pos = pos(end)+1;
    
  else % check type of all found options starting with the last one
    
    if isa(type,'char')
      for p = length(pos):-1:1
        if isa(option_list{pos(p)+1},type), pos = pos(p)+1; return, end
      end
    elseif isa(type,'cell')
      for p = length(pos):-1:1
        if any(cellfun(@(x) isa(option_list{pos(p)+1},x),type))
          pos = pos(p)+1; return
        end
      end
    end

    pos = 0;
  end
end
