function grains = transform(grains,fun)
% apply an arbitrary spatial transformation to a grain map
%
% Applies fun to every vertex of the grain boundaries, leaving mean
% orientations, phase and all other properties untouched. Unlike
% <grain2d.rotate.html |rotate|>, fun need not be a rigid transformation -
% it may be any map from position to position. Since all grain boundary
% quantities (vertices, boundary segments, triple points, ...) are derived
% from the same underlying vertex list, transforming it is enough to keep
% the whole grain map consistent.
%
% Useful together with <EBSD.transform.html |EBSD/transform|> to check
% that reconstructing grains commutes with a spatial transformation, i.e.
% that calcGrains on a transformed EBSD map agrees with transforming the
% grains reconstructed from the untransformed map.
%
% Syntax
%   grainsT = transform(grains,fun)
%
% Input
%  grains - @grain2d
%  fun    - function handle, @vector3d -> @vector3d, or a @spatialTransform
%
% Output
%  grains - @grain2d with transformed vertices
%
% See also
% grain2d/rotate EBSD/transform spatialTransform

if isa(fun,'spatialTransform'), T = fun; fun = @(pos) eval(T,pos); end

grains.allV = fun(grains.allV);

end
