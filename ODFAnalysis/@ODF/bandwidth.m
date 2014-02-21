function b = bandwidth(odf)
% bandwidth of the ODF

b = zeros(size(odf.components));
for i = 1:numel(odf.components)
  b(i) = odf.components{i}.bandwidth;
end
b = max(b);
