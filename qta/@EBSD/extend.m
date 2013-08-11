function ext = extend(ebsd)
% returns the boundings of spatial EBSD data
%
% Output
% ext - extend as [xmin xmax ymin ymax zmin zmax]
%

xyz = [];
if isProp(ebsd,'x'), xyz = [xyz,ebsd.prop.x];end
if isProp(ebsd,'y'), xyz = [xyz,ebsd.prop.y];end
if isProp(ebsd,'z'), xyz = [xyz,ebsd.prop.z];end

ext = reshape([min(xyz);max(xyz)],1,[]);
