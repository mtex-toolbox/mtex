%% Miller Indices
%
%%
% A direction in the specimen is written in the specimen axes X, Y, Z. A
% direction in the *crystal* is written in the crystal axes $\vec a$, $\vec
% b$, $\vec c$, and its coordinates are the Miller indices. Both are
% directions in the same three dimensional space - what differs is the frame
% the numbers refer to, and for a crystal that frame is in general neither
% orthogonal nor normalised.

%% The Crystal Reference Frame
%
% Miller indices mean nothing without the lattice they are counted in, so
% the starting point is always a
% <crystalSymmetry.crystalSymmetry.html |crystalSymmetry|>.

cs = crystalSymmetry('triclinic',[5.29,9.18,9.42],[90.4,98.9,90.1]*degree,...
  'X||a*','Z||c','mineral','Talc');

%%
% It carries the lengths and the angles of the unit cell, and hence the
% three lattice axes as directions in the Cartesian crystal frame.

a = cs.aAxis

%%

b = cs.bAxis

%%

c = cs.cAxis

%%
% Talc is triclinic, so these three are not at right angles. The unit-cell
% angle between $\vec a$ and $\vec c$ is $\beta=98.9^\circ$.

metricAngleAC = angle(a,c,'noSymmetry') ./ degree

%%
% The |'noSymmetry'| option is essential for reading the metric angle.
% Without it, |angle| compares symmetry-equivalent Miller directions; the
% inversion in this triclinic symmetry would select $-\vec c$ and report the
% smaller angle $81.1^\circ$ instead.

%% Lattice Directions
%
% A lattice direction $\vec m = u \cdot \vec a + v \cdot \vec b + w \cdot
% \vec c$ is the direction from one lattice point to another, written
% $[uvw]$. In MTEX it is a variable of type <Miller.Miller.html |Miller|>.

m = Miller(1,0,1,cs,'uvw')

%%
% Plotting it draws it as a point on the sphere, alongside the three crystal
% axes.

plot(m,'labeled','grid')

annotate([a,b,c],'label',{'a','b','c'},'backgroundcolor','w','textAboveMarker')

%%
% For triclinic and monoclinic symmetry MTEX draws the b-axis towards the
% east and c* out of the plane. That is a
% <plottingConvention.html plotting convention>, and a convention belongs to
% a reference frame - here to the frame of the crystal.

% change the plotting convention of the crystal frame
cs.frame.how2plot.east = cs.aAxis;

plot(m,'labeled','grid')

annotate([a,b,c],'label',{'a','b','c'},'backgroundcolor','w','textAboveMarker')

%%
% The same direction, the same crystal, a different view: a now points east.

%% Lattice Planes
%
% A lattice plane is named by its normal, $\vec n = h \cdot \vec a^* + k
% \cdot \vec b^* + \ell \cdot \vec c^*$, written $(hkl)$. The starred axes
% are the reciprocal lattice, defined so that $\vec a^*$ is perpendicular to
% both $\vec b$ and $\vec c$, and so on. Their construction from the lattice
% metric is explained in <LatticeMetric.html Lattice Metric and Plane
% Geometry>.
%
% The indices also describe where a plane cuts the direct axes. A member with
% plane equation $\vec x\cdot\vec n=q$ has fractional intercepts
% $q/h$, $q/k$ and $q/\ell$ along $\vec a$, $\vec b$ and $\vec c$. A zero
% index means an infinite intercept, so the plane is parallel to that axis.
%
% In the schematic, the $(213)$ plane is drawn with $q=6$. It therefore
% meets the axes at $3\vec a$, $6\vec b$ and $2\vec c$, and its normal is
% $2\vec a^*+\vec b^*+3\vec c^*$.
%
% <<latticePlaneNormal.png>>
%
% If only the plane orientation matters, multiplying all indices by a common
% factor leaves the normal direction unchanged. It does not leave the full
% lattice-plane family unchanged: $(200)$ has twice the reciprocal-vector
% length and half the spacing of $(100)$. This distinction matters for
% diffraction and for <Miller.dspacing.html |dspacing|>.

n = Miller(1,0,1,cs,'hkl')

%%
% A plane is drawn as its normal by default, or as the great circle where it
% cuts the sphere, with the option |'plane'|.

hold on

% the normal direction
plot(n,'upper','labeled')

% the trace of the corresponding lattice plane
plot(n,'plane','linecolor','r','linewidth',2,'add2all')
hold off

%% Why $[101]$ and $(101)$ Are Not the Same Direction
%
% The two directions defined above carry the same three numbers, and the
% plot shows them at different places. The angle between them is

directReciprocalAngle = angle(m,n,'noSymmetry') ./ degree

%%
% They are about $31.7^\circ$ apart. Direct and reciprocal axes are parallel in every
% orthogonal lattice, including orthorhombic, tetragonal and cubic lattices.
% In a non-orthogonal lattice they generally are not, so a plane normal need
% not be parallel to the lattice direction with the same indices. This is
% why |Miller| always records which of the two it represents.

%% Trigonal and Hexagonal Convention
%
% Trigonal and hexagonal lattices are usually written with four indices,
% $[UVTW]$ and $(HKIL)$, because this makes the three equivalent basal axes
% explicit. The fourth index is redundant, as $U + V + T = 0$ and
% $H + K + I = 0$.

% import trigonal Quartz lattice structure
cs = loadCIF('quartz');

% a four digit lattice direction
m = Miller(2,1,-3,1,cs,'UVTW')

%%

% a four digit plane normal
n = Miller(1,1,-2,3,cs,'hkil')

%%

plot(m,'upper','labeled','backgroundColor','white','grid','on')
hold on
plot(n,'upper','labeled')
hold off

%%
% Which notation the indices are *displayed* in is set by |dispStyle|, and
% changing it changes nothing about the direction itself.

m.dispStyle = 'uvw';
mThreeIndex = round(m)

%%

n.dispStyle = 'hkl';
nThreeIndex = n

%%
% Internally every |Miller| is stored in Cartesian coordinates, exactly as a
% <vector3d.vector3d.html |@vector3d|> is. The indices are a way of reading
% it. The direct vector remains a direct vector when switching from |UVTW|
% to |uvw|, and the reciprocal normal remains reciprocal when switching from
% |hkil| to |hkl|. Four-to-three-index direct conversion can introduce a
% common fractional scale, so |round| reduces it to equivalent small integer
% indices; the reciprocal conversion simply drops the redundant |i|.

%% Next
%
% <LatticeMetric.html Lattice Metric and Plane Geometry> adds lengths and
% interplanar spacings to the directions introduced here. What crystal
% symmetry does to a direction - the equivalent directions it has, and how
% many - is <CrystalOperations.html Operations>. How the crystal axes are
% attached to the Cartesian frame is
% <CrystalReferenceSystem.html Reference System>.
