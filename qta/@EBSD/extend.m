function ext = extend(ebsd)
% returns the boundings of spatial EBSD data
%
%% Output
% ext - extend as [xmin xmax ymin ymax zmin zmax]
%

xyz = [];
if isfield(ebsd.options,'x'), xyz = [xyz,ebsd.options.x];end
if isfield(ebsd.options,'y'), xyz = [xyz,ebsd.options.y];end
if isfield(ebsd.options,'z'), xyz = [xyz,ebsd.options.z];end

ext = reshape([min(xyz);max(xyz)],1,[]);
