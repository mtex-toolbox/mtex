function s = option2str(options)
% transforms option list to comma separated list

if ~isempty(options)
  s = strcat(options,{', '});
  s = [s{:}];
  s = s(1:end-2);
else
  s = '';
end
