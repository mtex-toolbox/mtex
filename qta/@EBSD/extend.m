function ext = extend(ebsd)
% returns the boundings of spatial EBSD data
%
%% Output
% ext - extend as [xmin xmax ymin ymax zmin zmax]
%

X = get(ebsd,'X');
ext = reshape([min(X);max(X)],1,[]);