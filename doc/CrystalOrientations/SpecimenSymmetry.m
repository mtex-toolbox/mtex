%% Specimen Symmetry
%%
plottingConvention.default('y↑→x');
%%
% While <CrystalSymmetries.html crystal symmetry> is a property of the
% crystal lattice, specimen symmetry is a property of the *process* that
% formed the specimen. Rolling, for instance, leaves the texture unchanged
% under $180^\circ$ rotations about the rolling, the transverse and the
% normal direction, which is an orthorhombic specimen symmetry.
%
% Since orientations map crystal coordinates into specimen coordinates,
% specimen symmetry acts from the *left* and crystal symmetry from the
% *right* - this is discussed in detail in <OrientationSymmetry.html
% Symmetrically Equivalent Orientations>.
%
%% Defining a Specimen Symmetry
%
% Variables of type @specimenSymmetry are defined by their point group. In
% practice only a handful of point groups occur. The default, used whenever
% no specimen symmetry is given, is the trivial one.

ss = specimenSymmetry('1')

%%
% Orthorhombic specimen symmetry is the common choice for rolled material.
% It may be given either by its point group or by its name.

ss = specimenSymmetry('mmm')

%%
% Note the difference between |'1'| and |'triclinic'|: the latter is the
% point group $\bar 1$, which includes the inversion and therefore consists
% of two elements rather than one.

length(specimenSymmetry('1').rot)
length(specimenSymmetry('triclinic').rot)

%% The Effect on an ODF
%
% Let us illustrate what imposing a specimen symmetry does. We start from a
% unimodal ODF with trivial specimen symmetry.

cs = crystalSymmetry.load('quartz.cif');
odf = unimodalODF(orientation.byEuler(30*degree,50*degree,10*degree,cs), ...
  'halfwidth',15*degree)

%%
% Its pole figure shows a single peak per symmetrically equivalent
% direction.

plotPDF(odf,Miller(1,0,-1,0,cs),'contourf')
mtexColorbar

%%
% We note its texture index, i.e. the squared <SO3Fun.norm.html |norm|>,
% for comparison.

norm(odf)^2

%%
% Assigning an orthorhombic specimen symmetry symmetrises the function from
% the left. The pole figure now repeats the peak at every position
% equivalent under the specimen symmetry.

odf.SS = specimenSymmetry('mmm')

%%

plotPDF(odf,Miller(1,0,-1,0,cs),'contourf')
mtexColorbar

%%
% The symmetry is not merely a plotting option - it changes the function
% itself, and hence every quantity derived from it. The same density is now
% spread over symmetrically equivalent positions, so the texture index
% drops accordingly.

norm(odf)^2

%% Specimen Symmetry and the Specimen Reference Frame
%
% Which rotations are symmetries depends on how the specimen reference
% frame is aligned, so a monoclinic specimen symmetry has to state its
% mirror axis explicitly. The point group |'112'|, for example, is the two
% fold rotation about the z axis.

specimenSymmetry('112')

%%
% Aligning the axes with the rolling geometry is done by naming them, which
% only affects how the symmetry is annotated in plots.

ss = specimenSymmetry('mmm');
ss.frame = specimenFrame.rolling;
ss
