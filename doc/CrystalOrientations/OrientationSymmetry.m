%% Symmetrically Equivalent Orientations
%
%%
% An orientation never stands alone. Every symmetry operation of the crystal
% produces a rotation that maps the crystal frame onto the specimen frame
% just as well, and no measurement can tell them apart. The same is true for
% symmetry of the specimen. An orientation is therefore a whole class of
% rotations, and MTEX works with the class rather than with the
% representative that happened to be written down.

plottingConvention.default('y↑→x');

% hexagonal crystal symmetry, 6 rotations about the c axis
cs = crystalSymmetry('6')

%%

% specimen symmetry with a twofold axis along z
ss = specimenSymmetry('112')

%%

% a random orientation
ori = orientation.rand(cs,ss)

%% Which Side Acts
%
% An orientation takes crystal coordinates to specimen coordinates, so
% crystal symmetry acts on its input, from the right, and specimen symmetry
% on its output, from the left. The six crystal operations give

% symmetrically equivalent orientations with respect to crystal symmetry
ori * cs

%%
% Only the third Euler angle $\varphi_2$ changes, in steps of $60^\circ$,
% because $\varphi_2$ is the rotation applied first, i.e. the one acting in
% crystal coordinates - which is exactly where the crystal symmetry sits.
%
% Specimen symmetry produces the other kind of equivalence.

% symmetrically equivalent orientations with respect to specimen symmetry
ss * ori

%%
% Now $\varphi_1$ moves instead, the angle applied last. Both together give
% the full class, $2 \times 6 = 12$ orientations.

ss * ori * cs

%%
% <orientation.symmetrise.html |symmetrise|> is the shortcut for that
% product.

length(symmetrise(ori))

%% What This Looks Like in a Pole Figure
%
% One orientation and one crystal direction give not one pole but a whole
% set of them.

h = Miller(1,0,0,cs);

plotPDF(ori,h,'MarkerSize',10,'figSize','small')

%%
% Every dot is the same physical direction of the same crystal. Which of
% them a calculation happens to produce is an accident of how the
% orientation was written down, which is why every comparison in MTEX takes
% all of them into account.

%% Coincidences
%
% For orientations that sit on a symmetry axis, several of the equivalent
% rotations coincide. The identity orientation is the extreme case: its
% class has 12 members but only 6 distinct ones, which the option |'unique'|
% removes.

length(symmetrise(orientation.id(cs,ss),'unique'))

%% Symmetry in Every Computation
%
% Because the class is what matters, the angle between two orientations is
% the smallest angle over all equivalent pairs. Comparing a random
% orientation with each of the symmetric equivalents of the Goss orientation
% gives one and the same number.

ori = orientation.rand(cs);

angle(ori,symmetrise(orientation.goss(cs))) ./ degree

%%
% Switching symmetry off shows what those rotations really are: six
% different angles, of which the number above is the smallest.

angle(ori,symmetrise(orientation.goss(cs)),'noSymmetry') ./ degree

%%
% The |'noSymmetry'| flag is available wherever the distinction matters,
% among others for <orientation.dot.html |dot|>,
% <orientation.unique.html |unique|> and
% <orientation.calcCluster.html |calcCluster|>. Reach for it when a number
% comes out smaller than expected - and leave it alone otherwise, since the
% symmetry-aware answer is the physically meaningful one.

%% Next
%
% The region of rotation space that holds exactly one member of each class
% is the <OrientationFundamentalRegion.html Fundamental Region>. Symmetry of
% the specimen, and when it should be imposed at all, is
% <SpecimenSymmetry.html Specimen Symmetry>.

%#ok<*NOPTS>
