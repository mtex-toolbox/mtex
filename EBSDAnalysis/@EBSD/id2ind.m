function ind = id2ind(ebsd,id)
% find ind such that ebsd.id(ind) == id
%
% Syntax
%   ind = id2ind(ebsd,id)
%
% Input
%  ebsd - @EBSD
%  id - a list of id's as stored in ebsd.id
%
% Output
%  ind - a list indices such that ebsd.id(ind) == id

[~,ind] = ismember(id,ebsd.id);