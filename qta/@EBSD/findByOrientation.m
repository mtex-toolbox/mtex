function ebsd = findByOrientation(ebsd,q0,epsilon)
% return a set of EBSD within an epsilon region around q0
%
%% See also
% orientation/find



o = get(ebsd,'orientations');

ind  = find(o,q0,epsilon);

ebsd = subsref(ebsd,any(ind,2));
