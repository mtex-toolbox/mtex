function d = flatten(E)
% every tensor component of every element, one column per element

d = cell(numel(E.u),1);
for k = 1:numel(E.u), d{k} = reshape(double(E.u{k}),3^E.rank(k),[]); end
d = vertcat(d{:});

end
