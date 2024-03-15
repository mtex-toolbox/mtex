function ind = id2ind(gB3,id)
% find ind such that gB.id(ind) == id
%
% Syntax
%   ind = id2ind(gB,id)
%
% Input
%  gB - @grain3Boundary
%  id - a list of id's as stored in gB.id
%
% Output
%  ind - a list indices such that gB.id(ind) == id

[b,ind] = ismember(id,gB3.id);
if ~all(b)
  error 'id not found'
end
ind = reshape(ind, size(id));