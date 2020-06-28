%% Parent Child Variants
%
%%
% The crystallographic structure of most materials is dependend on external
% conditions as temperature and pressure. When the external conditions
% change the crystals may undergo a phase transition from the inital phase,
% often called parent phase, into the child phase. While both phases still
% have the same chemical composition their crystallographic structure might
% be quite different. A typical example are the alpha and beta phase of
% titanium. While the alpha phase is hexagonal

csAlpha = crystalSymmetry('622',[3 3 4.7],'mineral','Ti (alpha)')

%%
% the beta phase is cubic

csBeta = crystalSymmetry('432',[3.3 3.3 3.3],'mineral','Ti (beta)')

%%
% Let |oriParent|

oriParent = orientation.rand(csAlpha)

%%
% be the orientation of the atomic lattice befor phase transition and
% |oriChild| the orientation of the atomic lattice after the phase
% transition. Since during a phase transition the atoms reorder with
% respect to a minimal energy constraint, both orientations |oriParent| and
% |oriChild| are in a specific orientation relationship with respect to
% each other. In the case of alpha and beta Titanium the dominant
% orientation relationship is described by the Euler angles

alpha2beta = orientation.byEuler(135*degree, 90*degree, 355*degree, csAlpha, csBeta);

%%
% A corresponding child orientation would then be

oriChild = oriParent * inv(alpha2beta)

%%
% This orientation relationship is characterised by the properties that it
% alignes the c-axis direction of the hexagonal alpha phase with the [110]
% direction of the cubic beta phase and the [2-1-10] direction of the alpha
% phase with the  [-11-1] direction of the beta phase.

hAlpha = Miller({0,0,0,1},{2,-1,-1,0},csAlpha)
hBeta  = Miller({1,1,0},{1,1,1},csBeta)

plotPDF(oriParent,hAlpha,'layout',[2 2])
nextAxis
plotPDF(oriChild,hBeta)

%%
% We could also use these alignment rules to define the orientation
% relationship as

alpha2beta = orientation.map(Miller(0,0,0,1,csAlpha),Miller(1,1,0,csBeta),...
  Miller(2,-1,-1,0,csAlpha),Miller(-1,1,-1,csBeta))

%%
% The advantage of the above definition by the alignment of different
% crystal directions is that it is independent of the
% <CrystalReferenceSystem.html convention used for the hexagonal crystal
% coordinate system>.
%
%% Child Variants
%
% Due to crystal symmetry each orientation of a parent alpha grain has
% 12 different but symmetrically equivalent representations. 

oriParentSym = oriParent.symmetrise

%%
% Applying the |alpha2beta| phase relationship to these 12 different
% represenations we obtain 12 child orientations.

oriChild = oriParentSym * inv(alpha2beta)

%%
% However, with respect to cubic crystal symmetry the 12 child orientations
% are not all symmetrically equivalent anymore. In fact, they form 6 pairs
% of symmetrically equivalent orientations as depicted in the following
% inverse pole figure.

color = ind2color(14+(1:12));

plotIPDF(oriChild,color,vector3d.Z)

%%
% These 6 pairs are called the variants of the parent orientation
% |oriParent| with respect to the orientation relation ship |alpha2beta|.
% They can be computed more directly using the command
% <orientation.variants.html |variants|>.

oriChild = variants(alpha2beta,oriParent)

for i = 1:6
  plotIPDF(oriChild(i),ind2color(i),vector3d.Z,'label',i); hold on
end
hold off

%%
% As we can see each variant can be associated by a |variantId|. You can
% pick specific variants by their |variantId| using the syntax

oriChild = variants(alpha2beta,oriParent,2:3)

%%
% Sometimes one faces the inverse question, i.e., determine the |variantId|
% from a parent and a child orientation or a pair of child orientations.
% This can be done using the command <calcVariants.html |calcVariants|>
% which is discussed in detail in the section
% <ParentGrainReconstruction.html parent grain reconstruction>.

%% Parent Variants
%
% TODO


