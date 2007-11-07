function G = getgrid(odf,ind)
% get mods of the components
%
%% Input
%  odf - @ODF
%  ind - [double] indece to specific components (optional)
%
%% Output
%  G   - @SO3Grid of modal orientations

for i = 1:length(odf)
  if isa(odf(i).center,'SO3Grid'),G = odf(i).center;end
end

if nargin == 2
  G = quaternion(G,ind);
end
