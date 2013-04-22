function out = extract_argoption(option_list,option)
% extract options from option list
%
%% Input
%  option_list - Cell Array
%  option      - String Array
%
%% Output
%  out         - Cell Array
%
%% See also
% get_option set_option delete_option

if ~iscell(option), option = {option};end

out = {};
for o = 1:length(option_list)

  if ischar(option_list{o}) && any(strcmpi(option_list{o},option))
    out = [out,option_list(o:o+1)]; %#ok<AGROW>
  end

end
