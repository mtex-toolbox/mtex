function gW = gradientDir(ebsd,w,varargin)
% directional derivative of the orientations along a specimen direction
%
% The gradient is measured along the two lattice directions a1,a2, which are
% whatever the grid happens to be - not the specimen axes. Writing the
% unknown gradient as the 3 × 2 matrix G (tangent component × map direction)
% and the undivided differences as h_k = G a_k gives
%
%   [h1 h2] = G A      =>      G = [h1 h2] inv(A)
%   dO/dw   = G w      =      [h1 h2] (A \ w)
%
% so a direction is handled by solving for its coefficients in the lattice
% basis. This is what makes a rotated or sheared grid work: nothing here
% assumes a1 or a2 is aligned with an axis, which is where the matrix based
% @EBSDsquare/gradientX gave up with error('Todo').
%
% A is the map plane only, so a direction with a component out of that plane
% - z for a map in the xy plane - has no solution and yields NaN, matching
% what @EBSDsquare/gradientZ returned.
%
% Input
%  ebsd - @EBSD
%  w    - @vector3d, the specimen direction
%
% Output
%  gW - length(ebsd) × 1, the derivative along w

[g,A] = gradient(ebsd,varargin{:});

% A is in the map plane frame, so bring the lattice vectors back to the specimen frame
aP = inv(ebsd.rot2Plane) * vector3d([A(1,1) A(1,2)],[A(2,1) A(2,2)],[0 0]);
a1 = aP(1); a2 = aP(2);

% undo the per-direction normalisation, on plain vector3d - h_k = dO/da_k
h1 = vector3d(g(:,1)) .* norm(a1);
h2 = vector3d(g(:,2)) .* norm(a2);

% coefficients of w in the lattice basis, least squares so that an
% out-of-plane component shows up as a residual rather than being dropped
P = [a1.x a2.x; a1.y a2.y; a1.z a2.z];
wq = normalize(w);
wv = [wq.x; wq.y; wq.z];
c = P \ wv;

if norm(P*c - wv) > 1e-10
  gW = vector3d.nan(size(g,1),1);
  return
end

gW = h1 .* c(1) + h2 .* c(2);

% restore the tangent type, where gradient produced one
if isa(g,'SO3TangentVector')
  % oriRef, not .rot - the latter shows one side of the pair as a stand-in
  oriRef = g.oriRef;
  gW = SO3TangentVector(gW, oriRef(:,1), g.tangentSpace);
end

% in the shape of the data, so a gridded map gives a map shaped gradient
gW = reshape(gW,size(ebsd));

end
