function mN = meshNorm(G,varargin)
% compute the maximal distance of a point on the meshNorm of a spherical grid
%
% The mesh norm $\delta$ ist the maximum of the minimal distance $d(x,y)$
% of any point $y$ on the sphere to any point $x$ of the grid $G$.
% 
% $$ delta = \max_{x \in S^2} \min_{y \in G} d(x,y)$$
% 
%
% Syntax
%
%   delta = meshNorm(G)
%
% Input
%  G - spherical grid @vector3d
%
% Output
%  delta - mesh norm
%
% See also
% 

[V,C] = calcVoronoi(G);

Vxyz = V.xyz;
Gxyz = G.xyz;

d = zeros(length(G),1);
for k = 1:length(G)

  d(k) = min(Vxyz(C{k},:) * Gxyz(k,:).');
    
end

if G.antipodal, d = abs(dot); end

mN = acos(min(d));
