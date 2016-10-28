function ind = id2ind(ebsd,id)
% indexing of EBSD data
%
% Syntax
%   ind = id2ind(ebsd,id)
%

ind = zeros(size(id));
ebsdId = ebsd.id;

for i = 1:numel(id)
  ind(i) = find(ebsdId == id(i));
end
