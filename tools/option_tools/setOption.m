function optList = setOption(optList,option,value)
% set option in option list
%
% Syntax
%   optList = setOption(option_list,option,value)
%   optList = setOption(option_list,{option1,option2,option3})
%
% Input
%  optList - struct
%  option  - string
%  value   - some type
%
% Output
%  optList - struct
%
% See also
% checkOption get_option delete_option


if ~isempty(option)>0
  
  if nargin == 3
    optList.(option) = value;
  else
    optList.(option) = true;
  end
  
end
