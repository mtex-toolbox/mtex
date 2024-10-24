function ind = id2ind(grains3,id)
% find ind such that grains.id(ind) == id
%
% Syntax
%   ind = id2ind(grains,id)
%
% Input
%  grains - @grain2d
%  id - a list of id's as stored in grains.id
%
% Output
%  ind - a list indeces such that grains.id(ind) == id

[~,ind] = ismember(id,grains3.id);
if ~all(ind)
  error 'id not found'
end
ind = reshape(ind, size(id));