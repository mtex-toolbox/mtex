function out = extract_option(option_list,option,types)
% extract options from option list
%
%% Input
%  option_list - Cell Array
%  option      - String Array
%  types       - class names
%
%% Output
%  out         - Cell Array
%
%% See also
% get_option set_option delete_option

if ~iscell(option), option = {option};end
if nargin > 2 && ~iscell(types), types = {types};end

out = {};
for o = 1:length(option)

  if nargin > 2 && o <= length(types)
    pos = find_option(option_list,option{o},types{o});
    p = 1;
  else
    pos = find_option(option_list,option{o});
    p = 0;
  end
  
  if pos 
    out = [out,option_list(pos-p:pos)]; %#ok<AGROW>
  end 
end
