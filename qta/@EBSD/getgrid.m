function G = getgrid(ebsd,ind)
% get mods of the components
%
%% Input
%  ebsd - @EBSD
%  ind - [double] indece to specific components (optional)
%
%% Output
%  G   - @SO3Grid of modal orientations

G = union(ebsd.orientations); 

if nargin == 2
  G = quaternion(G,ind);
end
