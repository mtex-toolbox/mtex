%% Lattice Metric and Plane Geometry
%
%%
% <CrystalDirections.html Miller indices> identify a lattice direction or
% plane family. The *lattice metric* supplies the lengths and angles that
% turn those indices into physical geometry. It determines the length of
% $[uvw]$, the normal to $(hkl)$, and the spacing between neighbouring
% $(hkl)$ planes.
%
% In MTEX, a <crystalSymmetry.crystalSymmetry.html |crystalSymmetry|>
% bundles point symmetry with a crystal frame. The crystal frame carries
% the lattice basis and its metric; symmetry states which operations leave
% crystal data invariant. Keeping those ideas separate matters because a
% lattice metric can have more symmetry than the atoms placed in its cell.

cs = crystalSymmetry('12/m1',[5.2 6.3 7.1],...
  [90 106 90]*degree,'X||a','mineral','Example monoclinic crystal');

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
% the lattice. The cell geometry does not say which atoms or other motif are
% repeated at its translation points.

%% The Seven Crystal Systems
%
% A crystal system restricts which lattice parameters may differ. MTEX
% records the system in |cs.lattice| and supplies its conventional default
% angles. The constructor checks required equal axis lengths. For a
% monoclinic point group, it also checks the two right angles associated
% with the selected unique axis.
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
% pages on <CrystalReferenceSystem.html crystal reference frames> and
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
% The output is 223.5856 in the cube of the lattice-parameter unit. The
% defining duality is seen directly in the matrix of pairwise dot products.

dot_outer(directBasis,reciprocalBasis)

%%
% The result is the identity matrix. Reciprocal axes have inverse-length
% units, and MTEX uses the crystallographic convention without a factor
% $2\pi$. Direct and reciprocal axes are parallel in an orthogonal lattice;
% in a monoclinic or triclinic lattice they generally are not.
%
% The schematic shows the direct basis at the lower left and the reciprocal
% basis from a second lattice point. The red points are
% translation-equivalent positions, while the blue points illustrate a
% repeated motif. Notice in particular that $\vec a$ and $\vec a^*$ are not
% parallel.
%
% <<latticeReciprocalBasis.png>>

%% Lengths of Lattice Directions
%
% A direct-lattice direction is a real vector
%
% $$\vec m=u\vec a+v\vec b+w\vec c.$$
%
% Its <vector3d.norm.html |norm|> is therefore a physical length, not just a
% plotting radius. The indices are coefficients in the generally oblique
% lattice basis, not Cartesian components. For example, $[101]$ spans one
% $\vec a$ and one $\vec c$.

m = Miller(1,0,1,cs,'uvw');

norm(m)

%%
% The value 7.5563 is in the same units as |cs.abc|. Multiplying all indices
% by two leaves the geometric direction unchanged, up to numerical
% rounding, but doubles the vector length. The option |'noSymmetry'|
% compares the two vectors as written rather than searching their
% symmetry-equivalent directions.

angle(m,Miller(2,0,2,cs,'uvw'),'noSymmetry') ./ degree

%%

norm(Miller(2,0,2,cs,'uvw')) ./ norm(m)

%%
% The angle is numerically zero, while the length ratio is 2.
%
% Use <vector3d.normalize.html |normalize|> when only the direction matters.
% Keep the original magnitude when the lattice translation or Burgers-vector
% length is part of the calculation.

%% Interplanar Spacing
%
% The normal of $(hkl)$ is a reciprocal-lattice vector. MTEX uses the
% crystallographic convention without a factor $2\pi$, so its length is the
% inverse of the interplanar spacing returned by
% <Miller.dspacing.html |dspacing|>:
%
% $$ d_{hkl}=\frac{1}{\lVert\vec n_{hkl}\rVert}. $$

h = Miller(1,0,0,cs);

d100 = dspacing(h)

%%
% MTEX returns 4.9986, which is smaller than $a=5.2$. In this monoclinic
% cell, $\vec a$ is not perpendicular to the $(100)$ planes. The spacing is
% the component of $\vec a$ normal to those planes, not generally the
% length of $\vec a$.
%
% The same command works for a list. For a cubic lattice with parameter
% $a=3.6$, the familiar result is $d_{hkl}=a/\sqrt{h^2+k^2+l^2}$.

csCubic = crystalSymmetry('m-3m',[3.6 3.6 3.6]);
hCubic = Miller({1,0,0},{1,1,0},{1,1,1},csCubic);

dspacing(hCubic)

%%
% The $(100)$, $(110)$, and $(111)$ spacings are 3.6000, 2.5456, and
% 2.0785. In a cubic lattice the spacing decreases as the squared-index sum
% $h^2+k^2+l^2$ increases.

%% The Maths Behind the Metric
%
% Put the direct-basis vectors into $A=[\vec a\ \vec b\ \vec c]$. The
% *metric matrix* is the matrix of their pairwise dot products,
%
% $$G=A^{\mathrm T}A,\qquad G_{ij}=\vec a_i\mathbin{\cdot}\vec a_j.$$
%
% MTEX obtains it directly from the basis vectors.

metricMatrix = dot_outer(directBasis,directBasis)

%%
% The diagonal entries are $a^2$, $b^2$, and $c^2$. The off-diagonal
% entries contain the interaxial angles, so the nonzero $a$ -- $c$ terms
% record the monoclinic angle $\beta=106^\circ$.
%
% For the direct-index column $\mathbf u=(u,v,w)^{\mathrm T}$ and the
% reciprocal-index column $\mathbf h=(h,k,l)^{\mathrm T}$,
%
% $$\lVert\vec m\rVert^2=\mathbf u^{\mathrm T}G\mathbf u,
% \qquad G^*=G^{-1},\qquad
% d_{hkl}=\frac{1}{\sqrt{\mathbf h^{\mathrm T}G^*\mathbf h}}.$$
%
% These equations are the matrix form of the |norm| and |dspacing|
% calculations above. They also give $V=\sqrt{\det G}$ for the unit-cell
% volume.

%% What a Crystal Symmetry Does Not Store
%
% The crystal geometry used here contains point symmetry and a crystal frame
% with its lattice metric. It does not model an atomic basis, Wyckoff
% positions, or the translational parts of a space group. In particular,
% the 14 Bravais lattices distinguish translational centring, whereas
% |crystalSymmetry| retains the associated crystal system and point group.
%
% A CIF can supply lattice parameters and a space-group symbol. When MTEX
% constructs a |crystalSymmetry| from that information, it reduces the space
% group to its point group for this geometry. Structure factors and
% systematic absences therefore require information outside this model.

%% References
%
% * A. Authier,
% <https://www.iucr.org/education/pamphlets/4/full-text The reciprocal
% lattice>, IUCr Teaching Pamphlet 4, develops the direct and reciprocal
% bases, plane spacings, and their diffraction interpretation.
% * H. Wondratschek and M. I. Aroyo,
% <https://onlinelibrary.wiley.com/iucr/itc/Ac/ch1o5v0001/sec1o5o2o2/
% Metric tensors of direct and reciprocal lattices>, _International Tables
% for Crystallography A_, section 1.5.2.2, gives the tensor formulation.
% * The International Union of Crystallography,
% <https://www.iucr.org/resources/cif/dictionaries/browse/cif_core1 Core CIF
% dictionary>, standardises unit-cell lengths, angles, volumes, and
% reciprocal-cell quantities used by crystallographic files.
% * C. Giacovazzo, editor,
% <https://doi.org/10.1093/acprof:oso/9780199573653.001.0001 Fundamentals of
% Crystallography>, 3rd ed., Oxford University Press, 2011, places lattice
% geometry within structural crystallography and diffraction.

%% Next
%
% <CrystalOperations.html Operations> uses direct and reciprocal geometry
% for incidence tests, zone axes, angles, and multiplicities.
% <CrystalReferenceSystem.html Reference System> explains how the lattice
% basis is embedded in a Cartesian crystal frame.

%#ok<*NOPTS>
%#ok<*NASGU>
