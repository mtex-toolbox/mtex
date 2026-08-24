%% Phase Transitions
%
%%
% When a material changes phase in the solid state, the new crystals do not
% appear at random angles. The old lattice is still there while the new one
% forms, and the cheapest way to build it is to keep as many atomic planes
% as possible in place. The result is an *orientation relationship*: a fixed
% angular relation between parent and child lattices, the same at every
% place the transformation happened.
%
% Symmetry then does what it always does. If the parent lattice has 24
% rotations that leave it unchanged, the one relationship can be satisfied
% in many distinct ways, and each way gives a differently oriented child
% crystal. These are the *variants*, and one parent grain typically
% transforms into several of them at once.
%
% Below are the child orientations that a single parent grain can produce
% under the Kurdjumov-Sachs relationship, in a pole figure.

plottingConvention.default('y↑→x');

csParent = crystalSymmetry('m-3m',[3.65 3.65 3.65],'mineral','Austenite');
csChild  = crystalSymmetry('m-3m',[2.87 2.87 2.87],'mineral','Ferrite');

p2c = orientation.KurdjumovSachs(csParent,csChild);

% one parent grain, and the child orientations it can produce
oriParent = orientation.byEuler(0,0,0,csParent);
oriChild = variants(p2c,oriParent);

plotPDF(oriChild,Miller(0,0,1,csChild),'MarkerSize',8,'figSize','small')

%%
% Twenty-four variants from one parent, all from a single relationship.
% Kurdjumov-Sachs gives 24; the Nishiyama-Wassermann relationship gives 12.
% Which of them a real steel follows, and whether it follows one exactly, is
% a question the data has to answer rather than something to assume.
%
%% Reading the transformation backwards
%
% The practical problem is usually the reverse of the picture above. What
% survives to be measured is the child phase - martensite, ferrite, alpha
% titanium - while the parent that produced it has gone. Yet the parent
% grain structure is what controls the properties, and it is what a
% metallurgist wants to know.
%
% *Parent grain reconstruction* recovers it. Because all the children of one
% parent are variants of a single orientation, a group of neighbouring child
% grains whose orientations are mutually consistent with the relationship
% can be traced back to a common parent. It works in two steps that are
% worth keeping distinct: each child grain is first *transformed* to a
% candidate parent orientation, and neighbouring candidates that agree are
% then *merged* into one parent grain.
%
% The difficulty is that the first step is ambiguous. A single child grain is
% consistent with several possible parents, and choosing between them
% requires looking at the neighbours - which is why the algorithms below are
% graph problems rather than per-grain calculations.
%
%% Variants, packets and Bain groups
%
% Variants are often grouped, and two groupings are in common use. A
% *packet* collects variants sharing a habit plane - the parent plane the
% child lattice lines up with. A *Bain group* collects variants sharing a
% Bain correspondence, that is, which parent cube axis the child aligns to.
%
% These are two independent classifications of the same 24 variants, not two
% levels of one hierarchy. A variant belongs to a packet and to a Bain
% group, and neither is a subdivision of the other.
%
%% Where to start
%
% <ParentChildVariants.html Parent Child Variants> and
% <MartensiteVariants.html Martensite Variants> introduce relationships and
% variants, and are the pages the rest depend on.
% <OrientationRelationshipFit.html Fitting the Orientation Relationship>
% comes next in practice: the relationship in your material is probably not
% exactly the textbook one, and fitting it to the data before reconstructing
% makes a visible difference.
%
% Two complete worked reconstructions follow, one for steel and one for
% titanium: <MaParentGrainReconstruction.html Parent Austenite
% Reconstruction> and <TiBetaReconstruction.html Parent Beta
% Reconstruction>. Start with whichever matches your material.
%
% The algorithms behind them are described separately.
% <GrainGraphBasedReconstruction.html Grain Graph Based Reconstruction>
% reasons about grain-to-grain compatibility;
% <TriplePointBasedReconstruction.html Triple Point Based Reconstruction>
% uses the extra constraint available where three grains meet.
% <LowLevelParentGrainReconstruction.html Low Level Reconstruction> and
% <MaParentGrainReconstructionAdvanced.html Low Level Reconstruction 2>
% open up the individual steps for cases the automatic route handles badly.
%
% <TransformationTexture.html Transformation Texture> asks the forward
% question instead: given a parent texture and a relationship, what texture
% does the product phase have?
%
%% Next
%
% The relationships here are <Misorientations.html Misorientations> with
% extra structure. The grains being reconstructed come from
% <Grains.html Grains>, and the maps they come from are
% <EBSDAnalysis.html EBSD>.
%
