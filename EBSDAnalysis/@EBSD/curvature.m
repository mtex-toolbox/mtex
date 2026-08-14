function kappa = curvature(ebsd,varargin)
% computes the incomplete curvature tensor
%
% The curvature is only ever known within the measurement plane: a 2d map
% says nothing about how the orientation changes along its normal. So the
% tensor is assembled from the two in-plane directions and left NaN along
% ebsd.N.
%
% Syntax
%   kappa = curvature(ebsd)
%   kappa = curvature(ebsd,'stencil','full')   % passed on to the gradient
%
% Input
%  ebsd - @EBSD
%
% Output
%  kappa - @curvatureTensor
%
% Options
%  passed straight to <EBSD.gradient.html gradient>, e.g. |'stencil'|
%
% See also
% EBSD/gradient EBSD/calcGND

% The two in-plane directions. For the usual map in the xy plane rot2Plane
% is the identity, so these are X and Y and the third column is the one that
% comes out NaN - exactly what this function did when it was written for xy
% maps only. For a map with any other normal - a section through a 3d
% dataset, or a map that has been rotated - they follow the plane instead of
% staying at X and Y, which is the whole point: taking gradientX/gradientY
% of a map in the xz plane asks for a derivative along Y, and there is no
% such direction in the data.
rot = inv(ebsd.rot2Plane);
u = rot * vector3d.X;
v = rot * vector3d.Y;

gu = gradientDir(ebsd,u,varargin{:});
gv = gradientDir(ebsd,v,varargin{:});

kappa = dyad(gu,u) + dyad(gv,v);

% The component along the plane normal is unknown. Entry (i,j) of the tensor
% is gu_i u_j + gv_i v_j + gN_i N_j, so it is unknown exactly where N_j is
% nonzero - for N = Z that is the third column, which is what this function
% always did. A tilted plane genuinely loses more: its normal has several
% nonzero components, and each of them contaminates a whole column. That is
% a property of writing the tensor in the specimen basis, not a defect.
%
% NB this must be a mask on the columns, not dyad(vector3d.nan,N): NaN*0 is
% NaN, so the dyad marks the entire tensor unknown even for N = Z.
N = normalize(ebsd.N);
Nc = [N.x N.y N.z];

for j = find(~isnull(Nc))
  kappa{:,j} = NaN;
end

% make it a curvature tensor
kappa = curvatureTensor(kappa,'unit',['1/' ebsd.scanUnit]);

end
