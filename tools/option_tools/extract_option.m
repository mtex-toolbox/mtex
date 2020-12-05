function out = extract_option(option_list,option,types)
% extract options from option list
%
% Syntax
%   out = extract_option(option_list,option,types)
%
% Input
%  option_list - Cell Array
%  option      - String Array
%  types       - class names
%
% Output
%  out         - Cell Array
%
% See also
% get_option set_option delete_option

% extract options with argument
if nargin > 2

  option = ensurecell(option);  
  types = ensurecell(types);
  out = {};
  
  for o = 1:length(option)

    pos = find_option(option_list,option{o},types{o});
      
    if pos
      out = [out,option_list(pos-1:pos)]; %#ok<AGROW>
    end
  end
    
% extract options without argument  
else

  option_list = option_list(cellfun(@ischar,option_list));
  
  ind = cellfun(@(a) any(strcmpi(a,option_list)) ,option);
  out = option(ind);
  
end
