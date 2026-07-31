function option_list = delete_option(option_list,options,nparams)
% clear options in option list
%
% All occurrences of the options are removed, together with the |nparams|
% entries following each option name.
%
% Syntax
%   option_list = delete_option(option_list,{option1,option2,option3,...})
%   option_list = delete_option(option_list,option,nparams)
%
% Input
%  option_list - cell array
%  options     - option name(s), string or cell array of names
%  nparams     - number of values to delete along with the option name,
%                default 0, either a scalar or one entry per option
%
% Output
%  option_list - cell array
%
% See also
% check_option get_option set_option find_option


if nargin == 2, nparams = 0; end
if ~iscell(options), options = {options}; end
if isscalar(nparams), nparams = repmat(nparams,size(options)); end

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
    option_list(i:min(i+nparams(pos),end)) = [];
    
  else
    i = i+1;
  end
end
