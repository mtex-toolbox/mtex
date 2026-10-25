function check_volumeFull
% volume and fibreVolume against the integral over a grid of the region, for
% five frame pairs, the centers at a vertex of the region, cube and a
% generic one, three fibres and two radii; core/check_volume runs a lean
% selection of the same cases
%
% See also
% SO3Fun/volume SO3Fun/fibreVolume

checkVolumeCases({{'m-3m','1'}, {'m-3m','mmm'}, {'mmm','mmm'}, {'6/mmm','1'}, {'m-3m','exchange'}});

end
