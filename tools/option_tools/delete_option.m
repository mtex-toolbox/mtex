function out_list = delete_option(option_list,option,nparams,type)
% clear options in option list
%
% Syntax
%   value = set_option(option_list,{option1,option2,option3,...})
%   value = set_option(option_list,option,nparams)
%
% Input
%  option_list - Cell Array
%  option      - String
%  nparams     - number of parameters (optional)
%
% Output
%  out_list      - Cell Array
%
% See also
% check_option get_option set_option

i = 1;
while i<=length(option_list)

  % found match
  if (isa(option_list{i},'char') && any(strcmpi(option_list{i},option)))

    if nargin == 3    
      % delete specified number of parameters
      option_list(i:i+nparams) = [];      
    else       
      
      % delete until the next character
      next = cellfun(@ischar,option_list(i+1:end));
      if any(next)
        option_list(i:i-1+find(next,1,'first')) = [];
      else
        option_list(i:end) = [];
      end
    end       
  else
    i = i+1;
  end
end

out_list = option_list;
