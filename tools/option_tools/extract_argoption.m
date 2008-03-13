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
% get_option set_option clear_option

if ~iscell(option), option = {option};end

out = {};
for o = 1:length(option)

  pos = find_option(option_list,option{o});
  if pos
    out = {out{:},option_list{pos:pos+1}};
  end

end
