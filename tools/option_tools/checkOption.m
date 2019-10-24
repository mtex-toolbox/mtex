function out = checkOption(optStruct,option,value)
% check for option in option list
%
% Syntax
%   out = checkOption(option_list,option_name)
%   out = checkOption(option_list,option_name,value)
%
% Input
%  option_list - Cell Array
%  option_name - String
%  option      - String
%  type        - class
%
% Output
%  out         - true / false
%
%% See also
% get_option set_option find_option

if ~isfield(optStruct,option)
  out = false;
elseif nargin == 2
  
  if islogical(optStruct.(option))  
    out = optStruct.(option);
  end
  
else
  
  switch class(optStruct.(option))
  
    case 'char'
      
      out = strcmpi(optStruct.(option),value);
    
    otherwise %{'logical','double'}
      
      out = all(optStruct.(option) == value);
      
  end
end