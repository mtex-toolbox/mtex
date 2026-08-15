function gW = gradientDir(ebsd,w,varargin)
% directional derivative of the orientations along a specimen direction
%
% The gradient is measured along the two lattice directions a1,a2, which are
% whatever the grid happens to be - not the specimen axes. Writing the
% unknown gradient as the 3 x 2 matrix G (tangent component x map direction)
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
%  gW - length(ebsd) x 1, the derivative along w

[g,A] = gradient(ebsd,varargin{:});

% A is in the map plane frame, w is a specimen direction, so bring the two
% lattice vectors back to the specimen frame before resolving w in them.
% For a map in the xy plane rot2Plane is the identity and this is a no-op;
% for a map in, say, the xz plane it is what lets the in-plane directions be
% found at all - and what keeps the out of plane one correctly NaN, since
% the residual test below is then against the real map plane rather than
% against xy.
aP = inv(ebsd.rot2Plane) * vector3d([A(1,1) A(1,2)],[A(2,1) A(2,2)],[0 0]);
a1 = aP(1); a2 = aP(2);

% undo the per-direction normalisation: h_k = dO/da_k, not per unit length.
% Done on plain vector3d and re-wrapped at the end: combining two
% SO3TangentVectors goes through ensureCompatibleTangentSpaces, and the
% linear combination below is a statement about the components, not about
% the tangent space.
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

% in the shape of the data, so a gridded map gives a map shaped gradient and
% with it a map shaped curvature tensor - kappa(2,3) then addresses the pixel
% in row 2, column 3, as the matrix based @EBSDsquare/gradientX used to allow
gW = reshape(gW,size(ebsd));

end
