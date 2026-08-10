function A = orientBasis(A)
% pin a 2x2 lattice basis to the column major layout convention
%
% latticeBasis derives (a1,a2) from the unit cell, so which one comes first
% and which way each points is an arbitrary consequence of the vertex order
% of that cell. For anything symmetric in the two directions that does not
% matter, but a one sided difference is not symmetric - flipping a1 turns a
% forward difference into a backward one - so EBSD/gradient needs the choice
% pinned down rather than inherited.
%
% Same rule squarify's orientGrid uses for the matrix layout: column 1 is the
% direction closest to y, column 2 the one closest to x, both oriented
% towards increasing coordinates.
%
% Input / Output
%  A - 2 x 2, columns are the lattice step vectors
%
% See also
% latticeBasis EBSD/gradient

a1 = A(:,1); a2 = A(:,2);

% how horizontal each direction is
horiz = @(a) abs(a(1)) - abs(a(2));
h1 = horiz(a1); h2 = horiz(a2);

if abs(h1 - h2) <= 1e-12 * (norm(a1) + norm(a2))
  % A 45 degree grid: both directions are equally horizontal and the primary
  % rule has nothing to decide on - h1 and h2 are both 0 up to rounding, so
  % comparing them would pick whichever way the noise fell. Decide it here
  % instead, on the y component and then the x component. The choice is
  % arbitrary at this configuration, as it must be; the point is only that
  % it is the same choice every time.
  %
  % Note squarify is NOT routed through this yet and still has the noise
  % sensitive form - see TODO.md E13.
  if a1(2) ~= a2(2)
    isXFirst = a1(2) < a2(2);
  else
    isXFirst = a1(1) > a2(1);
  end
else
  isXFirst = h1 > h2;
end

if isXFirst, [a1,a2] = deal(a2,a1); end

% orient both towards increasing coordinates: dimension 1 along +y, 2 along +x
if a1(2) < 0, a1 = -a1; end
if a2(1) < 0, a2 = -a2; end

A = [a1, a2];

end
