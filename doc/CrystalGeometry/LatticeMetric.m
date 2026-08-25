%% Lattice Metric and Plane Geometry
%
%%
% Miller indices say which lattice direction or plane family is meant. The
% *lattice metric* supplies the lengths and angles that turn those indices
% into physical geometry. It determines the length of $[uvw]$, the normal
% to $(hkl)$ and the spacing between neighbouring $(hkl)$ planes.
%
% MTEX stores the metric in the
% <crystalSymmetry.crystalSymmetry.html |crystalSymmetry|> together with the
% point group and crystal reference frame.

cs = crystalSymmetry('12/m1',[5.2 6.3 7.1],...
  [90 106 90]*degree,'X||a','mineral','Example monoclinic crystal')

%% Reading the Lattice Parameters
%
% The three axis lengths and the three interaxial angles are available as
% |abc| and |abg|. MTEX does not attach a unit label to the axis lengths: it
% preserves the numerical scale supplied by the user or data file. Angstrom
% is common for crystallographic data, but any consistent length unit works.

cs.abc

%%

cs.abg ./ degree

%% The Unit Cell
%
% The unit cell is the parallelepiped spanned by $\vec a$, $\vec b$ and
% $\vec c$. Repeating it by integer multiples of these three vectors fills
% the lattice. A |crystalSymmetry| stores the geometry of this cell and its
% point symmetry, but not the atoms or other motif repeated with it.

%% The Seven Crystal Systems
%
% A crystal system restricts which lattice parameters may differ. MTEX
% records the system in |cs.lattice|, supplies its conventional default
% angles, and checks required equal axis lengths when a |crystalSymmetry| is
% constructed. It also checks the right-angle condition associated with the
% selected unique axis of a monoclinic point group.
%
% || crystal system || conventional lattice metric ||
% || triclinic || no required equal lengths or right angles ||
% || monoclinic || two right angles; the third angle may differ ||
% || orthorhombic || independent $a,b,c$; all angles $90^\circ$ ||
% || tetragonal || $a=b\ne c$; all angles $90^\circ$ ||
% || trigonal || conventional hexagonal setting in MTEX: $a=b\ne c$, $\gamma=120^\circ$ ||
% || hexagonal || $a=b\ne c$, $\gamma=120^\circ$ ||
% || cubic || $a=b=c$; all angles $90^\circ$ ||
%
% MTEX represents trigonal and hexagonal point groups using the same
% conventional hexagonal metric; their threefold and sixfold point
% symmetries distinguish the systems.
%
% The monoclinic point-group symbol also states which axis is unique. The
% pages on <CrystalReferenceSystem.html reference frames> and
% <SymmetryAlignment.html axis alignment> explain how those lattice axes
% are placed in MTEX's Cartesian crystal frame.

cs.lattice

%% The Reciprocal Basis
%
% Lattice planes are most naturally described in the basis dual to the
% direct-lattice vectors. If
%
% $$V=\vec a\cdot(\vec b\times\vec c),$$
%
% then
%
% $$\vec a^*=\frac{\vec b\times\vec c}{V},\qquad
%   \vec b^*=\frac{\vec c\times\vec a}{V},\qquad
%   \vec c^*=\frac{\vec a\times\vec b}{V}.$$
%
% The direct and reciprocal bases are dual: each direct axis has dot product
% one with its matching reciprocal axis and zero with the other two. MTEX
% provides them as |axes| and <crystalSymmetry.axesDual.html |axesDual|>.

directBasis = cs.axes;
reciprocalBasis = cs.axesDual;

cellVolume = abs(det(directBasis))

%%
% The volume is in the cube of the lattice-parameter unit. The defining
% duality is seen directly in the matrix of pairwise dot products.

dot_outer(directBasis,reciprocalBasis,'noSymmetry')

%%
% The result is the identity matrix. Reciprocal axes have inverse-length
% units, and MTEX uses the crystallographic convention without a factor
% $2\pi$. Direct and reciprocal axes are parallel in an orthogonal lattice;
% in a monoclinic or triclinic lattice they generally are not.
%
% The schematic shows the direct basis at the lower left and the reciprocal
% basis from a second lattice point. The red points are translation-equivalent
% positions; the blue points illustrate a repeated motif. Notice in
% particular that $\vec a$ and $\vec a^*$ are not parallel.
%
% <<latticeReciprocalBasis.png>>

%% Lengths of Lattice Directions
%
% A direct-lattice direction is a real vector
%
% $$\vec m=u\vec a+v\vec b+w\vec c.$$
%
% Its <vector3d.norm.html |norm|> is therefore a physical length, not just a
% plotting radius. For example, $[101]$ spans one $\vec a$ and one $\vec c$.

m = Miller(1,0,1,cs,'uvw')

norm(m)

%%
% The result is in the same units as |cs.abc|. Multiplying all indices by
% two leaves the geometric direction unchanged, up to rounding, but doubles
% the vector length.

angle(m,Miller(2,0,2,cs,'uvw')) ./ degree

%%

norm(Miller(2,0,2,cs,'uvw')) ./ norm(m)

%%
% Use <vector3d.normalize.html |normalize|> when only the direction matters.
% Keep the original magnitude when the lattice translation or Burgers-vector
% length is part of the calculation.

%% Interplanar Spacing
%
% The normal of $(hkl)$ is a reciprocal-lattice vector. MTEX uses the
% crystallographic convention without a factor $2\pi$, so its length is the
% inverse of the plane spacing:
%
% $$ d_{hkl}=\frac{1}{\lVert\vec n_{hkl}\rVert}. $$

h = Miller(1,0,0,cs)

d100 = dspacing(h)

%%
% This is smaller than $a=5.2$: in this monoclinic cell, $\vec a$ is not
% perpendicular to the $(100)$ planes. The spacing is the component of
% $\vec a$ normal to those planes, not generally the length of $\vec a$.
%
% The same command works for a list. For a cubic lattice with parameter
% $a=3.6$, the familiar result is $d_{hkl}=a/\sqrt{h^2+k^2+l^2}$.

csCubic = crystalSymmetry('m-3m',[3.6 3.6 3.6]);
hCubic = Miller({1,0,0},{1,1,0},{1,1,1},csCubic);

dspacing(hCubic)

%% What a Crystal Symmetry Does Not Store
%
% A |crystalSymmetry| contains the point symmetry, lattice metric and frame
% convention. It does not retain the atomic basis, Wyckoff positions or the
% translational parts of a space group. In particular, the 14 Bravais
% lattices distinguish translational centring, whereas |crystalSymmetry|
% retains the associated crystal system and point group. A CIF or
% space-group symbol can provide the lattice parameters and point group, but
% MTEX reduces the space group to that point group. Structure factors and
% systematic absences therefore require information outside this geometry
% model.

%% Next
%
% <CrystalOperations.html Operations> uses the metric to test whether a
% direction lies in a plane and to compute zone axes and multiplicities.
% <CrystalDirections.html Miller Indices> introduces direct and reciprocal
% notation. <CrystalReferenceSystem.html Reference System> explains how the
% lattice is embedded in a Cartesian crystal frame.

%#ok<*NOPTS>
%#ok<*NASGU>
