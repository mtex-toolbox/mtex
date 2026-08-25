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
% three crystal axes as directions in the specimen.

a = cs.aAxis

%%

b = cs.bAxis

%%

c = cs.cAxis

%%
% Talc is triclinic, so these three are not at right angles - $\vec a$ and
% $\vec c$ enclose $81^\circ$ here. Everything that follows is a consequence
% of that.

angle(a,c) ./ degree

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
% both $\vec b$ and $\vec c$, and so on.

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

angle(m,n) ./ degree

%%
% $32^\circ$ apart. In a cubic lattice they would coincide, because the
% reciprocal axes are then parallel to the direct ones. In any other lattice
% they do not, and a plane normal is not the lattice direction with the same
% indices. This is the single most common way to get a crystal direction
% wrong, and it is why |Miller| always records which of the two it is.

%% Trigonal and Hexagonal Convention
%
% Trigonal and hexagonal lattices are usually written with four indices,
% $[UVTW]$ and $(HKIL)$, because symmetrically equivalent directions are
% then easy to spot - they are permutations of the first three. The fourth
% index is redundant, as $U + V + T = 0$ and $H + K + I = 0$.

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
round(m)

%%

n.dispStyle = 'UVTW';
round(n)

%%
% Internally every |Miller| is stored in Cartesian coordinates, exactly as a
% <vector3d.vector3d.html |@vector3d|> is. The indices are a way of reading
% it, and |round| is needed above because converting between the notations
% leaves numbers that are integers only up to rounding.

%% Next
%
% What crystal symmetry does to a direction - the equivalent directions it
% has, and how many - is <CrystalOperations.html Operations>. How the
% crystal axes are attached to the Cartesian frame in the first place is
% <CrystalReferenceSystem.html Reference System>.
