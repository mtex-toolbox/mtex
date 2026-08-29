%% Martensite Variants
%
% This page applies the variant concept from
% <ParentChildVariants.html Parent and Child Variants> to measured EBSD
% data. The goal is to fit an austenite-to-ferrite orientation relationship
% and classify each child grain by variant, packet, and Bain group.
%
% The example is a plessite microstructure from the Emsland iron meteorite.
% Plessite comes from the Greek _plythos_, meaning filling iron. It is an
% intimate intergrowth of parent taenite (austenitic fcc) and child kamacite
% (bcc).
%
% Plessite develops at low temperature from retained taenite. It fills the
% spaces in a Widmanstaetten pattern between volumes already transformed to
% kamacite, with very thin taenite ribbons around them.
%
% Both child bcc and retained parent fcc phases occur in this map. The fcc
% orientations record the former parent grains in the planetary body.
% Those parent grains can easily reach dimensions of metres.

plottingConvention.default('y↑→x');
%#ok<*MINV>

% Import the EBSD data.
mtexdata emsland

% Extract the crystal symmetries.
csBcc = ebsd('Fe').CS;
csAus = ebsd('Aus').CS;

% Segment and smooth the grains.
[grains,ebsd] = calcGrains(ebsd,'angle',5*degree,'minPixel',2);
grains = smoothBoundary(grains,4);

%% Inspect the retained parent phase
%
% The map colours bcc measurements by the crystal direction parallel to
% the selected specimen direction. This is inverse pole figure colouring.
% Retained austenite grains are blue, and the grey lines are grain
% boundaries.

plot(ebsd('Fe'),ebsd('Fe').orientations)
hold on
plot(grains.boundary,'lineWidth',2,'lineColor','gray')
plot(grains('Aus'),'FaceColor','blue','DisplayName','Austenite')
hold off

%%
% Notice the small amount and size of the remaining fcc phase. Increasing
% nickel content stabilizes this high-temperature phase during cooling.
% The low-temperature bcc phase can dissolve at most 6% nickel, so the fcc
% phase must assimilate the excess.
%
% The amount and size of retained fcc are therefore indicators of the
% overall nickel content. An axis-angle plot tests whether the separate fcc
% regions have one common orientation.

plot(ebsd('Aus').orientations,'axisAngle')

%%
% The tight cluster shows that all fcc grains have nearly the same
% orientation. The small deviations are assumed to record deformation from
% high-speed collisions in the asteroid belt.
%
% The <orientation.mean.html |mean|> estimates the common parent
% orientation. The <quaternion.std.html |std|> reports its angular spread
% in degrees.

parentOri = mean(ebsd('Aus').orientations)
parentFit = std(ebsd('Aus').orientations) ./ degree

%%
% The measured spread is 1.49 degrees. This small value supports treating
% the separate retained regions as samples of one former parent grain.

%% Compare parent and child poles
%
% The next figure plots mean bcc grain orientations as blue points. Red
% points mark symmetrically equivalent poles of the retained parent
% orientation.

childOri = grains('Fe').meanOrientation;

hBcc = Miller({1,0,0},{1,1,0},{1,1,1},csBcc);
hFcc = Miller({1,0,0},{1,1,0},{1,1,1},csAus);

plotPDF(childOri,hBcc,'MarkerSize',5,'MarkerFaceAlpha',0.05,...
  'MarkerEdgeAlpha',0.1,'points',500);

nextAxis(1)
hold on
plot(parentOri * hFcc(1).symmetrise,'MarkerFaceColor','r')
xlabel('$(100)$','Color','red','Interpreter','latex')

nextAxis(2)
plot(parentOri * hFcc(3).symmetrise,'MarkerFaceColor','r')
xlabel('$(111)$','Color','red','Interpreter','latex')

nextAxis(3)
plot(parentOri * hFcc(2).symmetrise,'MarkerFaceColor','r')
xlabel('$(110)$','Color','red','Interpreter','latex')
hold off
drawNow(gcm)

%%
% Several red and blue poles nearly coincide. This pattern suggests a
% crystallographic OR between the two phases.
%
% The Kurdjumov-Sachs (KS) OR maps one parent {111}-fcc plane to one child
% {110}-bcc plane. Within those planes, one parent $\langle110\rangle$-fcc
% direction is parallel to one child $\langle111\rangle$-bcc direction.
%
% In a cubic crystal, a plane normal $(hkl)$ is parallel to the direction
% $[hkl]$ with the same indices. The pole figures can therefore be read as
% plane-normal or direction alignments.

%% Define and test the Kurdjumov-Sachs relationship
%
% MTEX provides |orientation.KurdjumovSachs(csAus,csBcc)|. Here the two
% parallelisms define the OR explicitly, which makes its meaning visible.

KS = orientation.map(Miller(1,1,1,csAus),Miller(0,1,1,csBcc),...
  Miller(-1,0,1,csAus),Miller(-1,-1,1,csBcc))

plotPDF(variants(KS,parentOri),'add2all',...
  'MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',2)

%%
% The black rings are the ideal KS child variants predicted from the
% retained parent. Their offsets from the blue measurements show that the
% mapped material does not follow the ideal relationship exactly.
%
% A parent-to-child <Misorientations.html misorientation> expresses the
% relative rotation between one measured child and the parent. The mean
% angular distance from these rotations to |KS| quantifies the mismatch.

mori = inv(childOri) * parentOri;
fitKS = mean(angle(mori,KS)) ./ degree

%%
% The ideal KS relationship has a mean deviation of 3.93 degrees from the
% measured rotations.

%% Fit the orientation relationship from a known parent
%
% Because the parent orientation is known here, a robust
% <orientation.mean.html |mean|> of all measured parent-to-child
% misorientations is a direct candidate for a better OR.

p2cMean = mean(mori,'robust')

plotPDF(childOri,hBcc,'MarkerSize',5,'MarkerFaceAlpha',0.05,...
  'MarkerEdgeAlpha',0.1,'points',500);
hold on
plotPDF(variants(p2cMean,parentOri),'add2all',...
  'MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',2)
hold off

fitMean = mean(angle(mori,p2cMean)) ./ degree

%%
% The rings now pass through the measured pole clusters more closely than
% the ideal KS rings. The mean deviation falls to 2.49 degrees, which
% confirms the visual improvement.

%% Fit the relationship without a known parent
%
% If no parent orientation remains, <calcParent2Child.html
% |calcParent2Child|> can estimate the OR solely from child-to-child
% misorientations. The method iteratively assigns symmetry operators and
% refines the OR.
%
% The iterative method needs an initial OR not too far from the actual OR
% when used as a local fit. The current default also scans the fundamental
% region for promising starting points. We supply the
% Nishiyama-Wassermann (NW) OR as the initial candidate.

NW = orientation.NishiyamaWassermann(csAus,csBcc)

% Extract neighbouring pairs of child grains and their orientations.
grainPairs = neighbors(grains('Fe'));
oriPairs = grains(grainPairs).meanOrientation;

% Estimate the parent-to-child orientation relationship.
p2cIter = calcParent2Child(oriPairs,NW)

% Compare it with the measured parent-to-child misorientations.
fitIter = mean(angle(mori,p2cIter)) ./ degree

%%
% The OR computed only from child-to-child misorientations fits the measured
% parent-to-child rotations with a mean deviation of 2.49 degrees. It fits
% about as well as the robust mean.
%
% This agreement is the important check before the OR is used for
% classification.

%% Assign variant, packet, and Bain group IDs
%
% A <ParentChildVariants.html variant> is one crystallographically
% equivalent child orientation predicted from a single parent orientation
% by a known OR. A variant ID identifies one member of that ordered set.
%
% <calcVariantId.html |calcVariantId|> compares every measured child
% orientation with all predictions. It returns the closest variant ID and
% the associated packet and Bain group IDs.

[variantId,packetId,bainId] = ...
  calcVariantId(parentOri,childOri,p2cIter);

%% Classify individual variants
%
% Ordered colours give nearby variant IDs related colours. In the pole
% figures, overlap makes the individual coloured points difficult to
% distinguish.

variantColor = ind2color(variantId,'ordered');
plotPDF(childOri,variantColor,hBcc,'MarkerSize',5);

%%
% The axis-angle plot separates the clusters. Each compact colour cluster
% is a group of measured child grains assigned to one variant ID.

plot(childOri,variantColor,'axisAngle')

%% Classify packets
%
% A *packet* is a coarse grouping of variants that share the same habit
% plane. For KS-type martensite, it records which parent {111} plane aligns
% with the child lattice.
%
% The habit plane is the interface along which atomic rearrangement occurs
% during the phase transition. Variants within one packet are related by
% specific symmetries, and the packet ID identifies that group.

packetColor = ind2color(packetId);
plotPDF(childOri,packetColor,hBcc,'MarkerSize',5,'points',1000);

nextAxis(1)
hold on
opt = {'MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',3};
plot(parentOri * hFcc(1).symmetrise,opt{:})
xlabel('$(100)$','Color','red','Interpreter','latex')

nextAxis(2)
plot(parentOri * hFcc(3).symmetrise,opt{:})
xlabel('$(111)$','Color','red','Interpreter','latex')

nextAxis(3)
plot(parentOri * hFcc(2).symmetrise,opt{:})
xlabel('$(110)$','Color','red','Interpreter','latex')
hold off
drawNow(gcm)

%%
% Blue, orange, yellow, and green mark the four packet IDs. In the {110}-bcc
% panel, each colour is selected by which equivalent (111)-austenite axis
% aligns with the (110)-ferrite axis.
%
% Plotting the same colours on the grain map reveals the spatial extent of
% each child packet.

plot(grains('Fe'),packetColor)

%% Classify Bain groups
%
% A *Bain group* is a coarse grouping by Bain correspondence. It records
% which parent {001} cube-axis plane aligns with the child lattice.
%
% Bain notation concisely represents a transformation path and the
% geometric correspondence between the parent and child crystal structures.
% Each Bain group ID identifies one such correspondence.
%
% Packet and Bain group are independent classifications of the same
% variant. They are not two levels of one hierarchy.

bainColor = ind2color(bainId);
plotPDF(childOri,bainColor,hBcc,'MarkerSize',5,'points',1000);

nextAxis(1)
hold on
opt = {'MarkerFaceColor','none','MarkerEdgeColor','k','linewidth',3};
plot(parentOri * hFcc(1).symmetrise,opt{:})
xlabel('\((100)\)','Color','red','Interpreter','latex')

nextAxis(2)
plot(parentOri * hFcc(3).symmetrise,opt{:})
xlabel('\((111)\)','Color','red','Interpreter','latex')

nextAxis(3)
plot(parentOri * hFcc(2).symmetrise,opt{:})
xlabel('\((110)\)','Color','red','Interpreter','latex')
hold off
drawNow(gcm)

%%
% Blue, orange, and yellow mark the three Bain group IDs. The colours are
% distinguished by which equivalent (100)-austenite axis aligns with the
% (100)-ferrite axis.
%
% The map shows how these child Bain groups are distributed in the
% microstructure.

plot(grains('Fe'),bainColor)

%% References
%
% * T. Nyyssönen, M. Isakov, P. Peura, and V.-T. Kuokkala,
% <https://doi.org/10.1007/s11661-016-3462-2 Iterative determination of the
% orientation relationship between austenite and martensite from a large
% amount of grain pair misorientations>, _Metallurgical and Materials
% Transactions A_ 47 (2016), 2587-2590, gives the iterative OR-fitting
% method used by |calcParent2Child|.
% * S. Morito, X. Huang, T. Furuhara, T. Maki, and N. Hansen,
% <https://doi.org/10.1016/j.actamat.2006.07.009 The morphology and
% crystallography of lath martensite in alloy steels>, _Acta Materialia_ 54
% (2006), 5323-5331, gives the variant, packet, and block crystallography
% behind the classification used here.

%% Next
%
% Continue with <TiBetaReconstruction.html Parent Beta Reconstruction> to
% use a fitted orientation relationship and variant consistency to recover
% a parent-grain map when only the child phase remains.
