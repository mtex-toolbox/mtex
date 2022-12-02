function s = char(SO3F)
% odf -> char

s = strvcat(char(SO3F.CS,'verbose','symmetryType'),...
  char(SO3F.SS,'verbose','symmetryType'));

for i = 1:length(SO3F.components)
  s = strvcat(s,' ',char(SO3F.components{i}),...
  ['    weight: ',num2str(mean(SO3F.components(i)))]);
ensd

end