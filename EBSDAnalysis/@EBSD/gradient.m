function [g,A] = gradient(ebsd,varargin)
% orientation gradient along the two lattice directions
%
% Works on any @EBSD - a plain list, a phase subset, a gridified map - by
% placing every pixel on the virtual lattice ebsd.lattice derives from the
% unit cell, so it needs neither a matrix layout nor an axis aligned grid.
% A rotated or sheared grid is handled by the same code.
%
% Syntax
%   g = gradient(ebsd)                    % one sided (default)
%   g = gradient(ebsd,'leastSquares')     % fit over the whole 1-hop stencil
%   g = gradient(ebsd,'basis',[a1 a2])    % use an explicit basis
%   [g,A] = gradient(ebsd)
%
% Input
%  ebsd - @EBSD
%
% Output
%  g - length(ebsd) x 2 @vector3d, g(:,k) = d(orientation) / d(a_k), in the
%      left tangent space, i.e. log(ori(p+a_k),ori(p))/|a_k|
%  A - 2 x 2 basis actually used, columns a1, a2 (map plane components)
%
% Options
%  leastSquares - least squares fit over every available 1-hop neighbour,
%                 which in the interior is the central difference. Better
%                 behaved, but it moves every GND / WBV number, so it is
%                 opt-in and one sided stays the default.
%  basis        - 1x2 @vector3d, use these as (a1,a2) instead of the ones
%                 derived from the unit cell
%
% Description
% The one sided form takes the neighbour at +a_k, and falls back to -a_k
% (negated) only where +a_k lies outside the map. A missing neighbour inside
% the map - a notIndexed hole, a different phase, the far side of a grain
% boundary - yields NaN and does NOT fall back, which is what the matrix
% based @EBSDsquare/gradient1 does and what keeps existing GND / WBV numbers
% unchanged.
%
% See also
% EBSD/gradientX EBSD/curvature EBSD/calcGND EBSD/lattice

% --- basis --------------------------------------------------------------
aIn = get_option(varargin,'basis',[]);
if ~isempty(aIn)
  % an explicit basis is used exactly as given - no pinning, since the
  % caller has already decided what dimension 1 is (e.g. @EBSDsquare
  % handing over its own d1,d2 so the numbers stay bit identical)
  a1 = aIn(1); a2 = aIn(2);
  A = [a1.x a2.x; a1.y a2.y];
else
  A = orientBasis(ebsd.lattice.A);
  a1 = vector3d(A(1,1),A(2,1),0);
  a2 = vector3d(A(1,2),A(2,2),0);
end

nE = length(ebsd);

% --- lattice index and neighbour lookup ---------------------------------
% recomputed against A rather than reusing ebsd.lattice.ij, because ij is
% only meaningful together with the basis it was built from
ij = assignGridIndex([ebsd.pos.x(:), ebsd.pos.y(:)], A);
[ij2ebsd,ij2slot,ijMin,ijSize] = latticeLookup(ij);

inBox = @(IJ) IJ(:,1) >= ijMin(1) & IJ(:,1) <= ijMin(1)+ijSize(1)-1 & ...
              IJ(:,2) >= ijMin(2) & IJ(:,2) <= ijMin(2)+ijSize(2)-1;

lookup = @(IJ,use) lookupAt(IJ,use,ij2ebsd,ij2slot,nE);

step = [norm(a1), norm(a2)];
e = [1 0; 0 1];

if check_option(varargin,'leastSquares')
  g = lsqGradient(ebsd,ij,inBox,lookup,A,a1,a2,nE);
  return
end

% --- one sided ----------------------------------------------------------
g = vector3d.nan(nE,2);

for k = 1:2

  fwd = ij + e(k,:);
  bwd = ij - e(k,:);

  useFwd = inBox(fwd);
  useBwd = ~useFwd & inBox(bwd);

  idx = zeros(nE,1);
  idx(useFwd) = lookup(fwd,useFwd);
  idx(useBwd) = lookup(bwd,useBwd);

  sgn = zeros(nE,1);
  sgn(useFwd) =  1;
  sgn(useBwd) = -1;

  gk = logNeighbour(ebsd,idx,nE);
  g(:,k) = gk .* (sgn ./ step(k));

end

g = asTangent(g,ebsd);

end

% =========================================================================
function g = asTangent(g,ebsd)
% restore the SO3TangentVector type wherever it is well defined
%
% log(...,leftVector) returns an SO3TangentVector, but accumulating into a
% preallocated vector3d strips it back to the base class. The type carries
% the base orientation and ONE crystal symmetry, so it only exists for a
% single indexed phase - which is also the only case the matrix based
% gradient1 / gradient2 ever supported, since they read ebsd.orientations
% and that errors on multi phase data. Multi phase keeps the plain
% vector3d: new capability rather than a regression, and every consumer
% (dyad -> curvature -> GND / WBV) treats the two alike, since
% SO3TangentVector is a vector3d.

pid = ebsd.indexedPhasesId;
if numel(pid) ~= 1, return; end

ori = orientation(ebsd.rotations(:),ebsd.CSList(pid));
g = SO3TangentVector(g, repmat(ori,1,size(g,2)), SO3TangentSpace.leftVector);

end

% =========================================================================
function idx = lookupAt(IJ,use,ij2ebsd,ij2slot,~)
% ebsd rows at the lattice indices IJ(use,:), 0 where the lattice site is
% inside the bounding box but carries no measurement

if ~any(use), idx = zeros(0,1); return; end
idx = ij2ebsd(ij2slot(IJ(use,:)));

end

% =========================================================================
function gk = logNeighbour(ebsd,idx,nE)
% log(ori(idx), ori(p)) per pixel, NaN wherever the pair is not comparable
%
% Not comparable means: no neighbour there, either side notIndexed, the two
% sides are different phases, or - when grainId is available - they are in
% different grains.

gk = vector3d.nan(nE,1);

valid = idx > 0;
valid(valid) = ebsd.isIndexed(valid) & ebsd.isIndexed(idx(valid));
if ~any(valid), return; end

% avoid grain boundaries if possible
if ebsd.hasGrainId
  gid = ebsd.grainId(:);
  valid(valid) = gid(valid) == gid(idx(valid));
end

% per phase, since orientations of different phases are not comparable and
% ebsd.orientations errors on multi phase data
for p = ebsd.indexedPhasesId

  use = valid;
  use(use) = ebsd.phaseId(use) == p & ebsd.phaseId(idx(use)) == p;
  if ~any(use), continue; end

  o1 = orientation(ebsd.rotations(idx(use)),ebsd.CSList(p));
  o2 = orientation(ebsd.rotations(use),ebsd.CSList(p));
  gk(use) = log(o1,o2,SO3TangentSpace.leftVector);

end

end

% =========================================================================
function g = lsqGradient(ebsd,ij,inBox,lookup,A,a1,a2,nE)
% least squares fit of the gradient over every available 1-hop neighbour
%
% For each pixel solve  min_G sum_q |G d_q - h_q|^2  with d_q the 2d offset
% to neighbour q and h_q = log(ori(q),ori(p)). With a symmetric pair present
% this is exactly the central difference. Accumulated as the 2x2 normal
% matrix sum(d d') and the 3x2 right hand side sum(h d'), then inverted in
% closed form.

stencil = [1 0; -1 0; 0 1; 0 -1; 1 -1; -1 1];
% the hex stencil contains the square one, and offsets that do not exist on
% a square lattice simply find no neighbour, so one list serves both

M11 = zeros(nE,1); M12 = zeros(nE,1); M22 = zeros(nE,1);
Rx = zeros(nE,2); Ry = zeros(nE,2); Rz = zeros(nE,2);

for s = 1:size(stencil,1)

  IJn = ij + stencil(s,:);
  use = inBox(IJn);
  idx = zeros(nE,1);
  idx(use) = lookup(IJn,use);

  h = logNeighbour(ebsd,idx,nE);
  ok = ~isnan(h);
  if ~any(ok), continue; end

  d = stencil(s,:) * A.';          % physical offset, 1 x 2
  w = double(ok);

  M11 = M11 + w * d(1)^2;
  M12 = M12 + w * d(1)*d(2);
  M22 = M22 + w * d(2)^2;

  hx = h.x; hy = h.y; hz = h.z;
  hx(~ok) = 0; hy(~ok) = 0; hz(~ok) = 0;

  Rx = Rx + [hx*d(1), hx*d(2)];
  Ry = Ry + [hy*d(1), hy*d(2)];
  Rz = Rz + [hz*d(1), hz*d(2)];

end

det = M11.*M22 - M12.^2;
bad = ~(abs(det) > 0);           % fewer than 2 independent neighbours

% G = R * inv(M), per pixel; G is 3 x 2 (tangent component x map direction)
iv = @(R) deal((R(:,1).*M22 - R(:,2).*M12)./det, ...
               (R(:,2).*M11 - R(:,1).*M12)./det);
[Gx1,Gx2] = iv(Rx);
[Gy1,Gy2] = iv(Ry);
[Gz1,Gz2] = iv(Rz);

G1 = vector3d(Gx1,Gy1,Gz1);      % d(ori)/dx
G2 = vector3d(Gx2,Gy2,Gz2);      % d(ori)/dy

% report along the two lattice directions, as the one sided branch does
g = vector3d.nan(nE,2);
g(:,1) = (G1*a1.x + G2*a1.y) ./ norm(a1);
g(:,2) = (G1*a2.x + G2*a2.y) ./ norm(a2);
g(bad,:) = vector3d.nan;

g = asTangent(g,ebsd);

end
