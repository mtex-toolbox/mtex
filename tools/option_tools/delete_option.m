function option_list = delete_option(option_list,options,nparams)
% clear options in option list
%
% Syntax
%   value = set_option(option_list,{option1,option2,option3,...})
%   value = set_option(option_list,option,nparams)
%
% Input
%  option_list - cell array
%  option      - char or cell array
%  nparams     - number of parameters (optional)
%
% Output
%  out_list      - Cell Array
%
% See also
% check_option get_option set_option


if nargin == 2, nparams = 0; end
if length(options) > length(nparams)
  nparams = repmat(nparams,size(options));
end

i = 1;
while i<=length(option_list)

  if ~isa(option_list{i},'char')
    i = i + 1;
    continue;
  end
  
  pos = find(strcmpi(option_list{i},options),1);
  
  % found match
  if ~isempty(pos)
   
    % delete specified number of parameters
    option_list(i:i+nparams(pos)) = [];
    
  else
    i = i+1;
  end
end
