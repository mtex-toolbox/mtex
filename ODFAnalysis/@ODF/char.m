function s = char(odf)
% odf -> char

s = strvcat(char(odf.CS,'verbose','symmetryType'),...
  char(odf.SS,'verbose','symmetryType'));

for i = 1:length(odf.components)
  s = strvcat(s,' ',char(odf.components{i}),...
  ['    weight: ',num2str(odf.weights(i))]);
end

end