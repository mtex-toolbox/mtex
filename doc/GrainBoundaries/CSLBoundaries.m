%% CSL Boundaries
%
% Most misorientations bring the lattices on the two sides of a boundary
% into no particular relation. At a coincidence site lattice (CSL)
% relationship, some sites of the two lattices coincide.
%
% The number $\Sigma$ is the reciprocal density of those sites. Thus, an
% exact $\Sigma 3$ relationship has one coincidence site for every three
% lattice sites. The $\Sigma 3$ relationship is the misorientation of a
% coherent annealing twin in a cubic metal.
%
% This does not make every measured $\Sigma 3$ segment a coherent or
% low-energy boundary. A CSL relationship fixes the three misorientation
% degrees of freedom, but not the two degrees that specify the boundary
% plane. The plane, chemistry, and deviation from the exact relationship
% also affect boundary energy and properties. Low $\Sigma$ is therefore a
% useful geometric classification, not a monotonic measure of
% specialness.
%
% Some low $\Sigma$ populations, especially coherent twins, resist
% intergranular corrosion and cracking. Increasing their fraction and
% breaking up the connected network of susceptible boundaries is the aim
% of grain boundary engineering. This page shows how to find and analyse
% them in an EBSD map.
%
% The workflow assumes <GrainReconstruction.html grain reconstruction>,
% <BoundaryMisorientations.html boundary misorientations>, and
% <MisorientationTheory.html misorientation theory>. The density section
% also uses <DensityEstimation.html kernel density estimation>.

%% Reconstruct the boundary network
%
% The example is a single-phase cubic iron map. MTEX's <CSL.html |CSL|>
% generator is for cubic symmetry. The plotting convention below matches
% the specimen frame stored with this data set.

plottingConvention.default('y↓→x');
mtexdata csl silent

% grain segmentation
[grains,ebsd] = calcGrains(ebsd);

% grain smoothing
grains = smoothBoundary(grains,5);

% plot the reconstructed grains by their mean orientations
plot(grains,grains.meanOrientation,'ipfDirection',zvector)

%% What the orientation map shows
% Thin bands of similar colours cross many of the larger grains. They are
% the first visual clue that this recrystallised material contains many
% annealing twins.

%% Compare the reconstruction with image quality
%
% Diffraction-pattern image quality often drops at a boundary. Plotting it
% beneath translucent orientation colours checks the reconstruction
% against a signal that was not used to classify the boundary.

plot(ebsd,log(ebsd.prop.iq),'figSize','large')
mtexColorMap black2white
setColorRange([.5,5])

% make the orientation layer translucent
hold on
plot(grains,grains.meanOrientation,'ipfDirection',zvector,...
  'FaceAlpha',0.4,'linewidth',3)
hold off

%% What the image-quality overlay shows
% Many dark image-quality bands follow the reconstructed interfaces. The
% narrow coloured lamellae remain visible through the translucent layer.

%% Detect the Sigma 3 boundaries
%
% <orientation.angle.html |angle|> measures the smallest distance between
% a boundary misorientation and the symmetrically equivalent ideal
% relationships. Here the fixed tolerance is 3 degrees.

% restrict the analysis to iron--iron boundaries
gB = grains.boundary('iron','iron')

% construct the ideal Sigma 3 misorientation
csl3 = CSL(3,ebsd.CS);

% select boundary segments within 3 degrees of Sigma 3
gB3 = gB(angle(gB.misorientation,csl3) < 3*degree);

% report their segment fraction
sigma3SegmentPercent = 100 * length(gB3) ./ length(gB)

% overlay the Sigma 3 segments on the existing plot
hold on
plot(gB3,'lineColor','gold','linewidth',3,'DisplayName','CSL 3')
hold off

%% How much of the network is Sigma 3
% The summary reports 17,569 iron--iron segments. Of these, 7,499, or
% 42.7 percent, lie within 3 degrees of $\Sigma 3$. The gold segments are
% not scattered randomly: many continue along complete runs from one
% triple point to the next.
%
% The tolerance is a choice. The Brandon criterion uses
% $15^\circ / \sqrt{\Sigma}$, which is 8.7 degrees for $\Sigma 3$ and
% narrows as $\Sigma$ increases. The 3 degree tolerance above is stricter.
% Neither tolerance determines the unmeasured boundary-plane inclination.

%% Triple points where Sigma 3 boundaries meet
%
% A triple point is where exactly three boundary segments meet and separate
% three real grains. Its |boundaryId| property gives the three incident
% segments. The condition below selects points where at least two of them
% match the $\Sigma 3$ relationship.
%
% <grainBoundary.isTwinning.html |isTwinning|> is the convenience form of
% the angular comparison used above. It also checks the phases on the two
% sides of each segment.

% logical list of Sigma 3 boundary segments
isCSL3 = grains.boundary.isTwinning(csl3,3*degree);

% logical list of triple points with at least two Sigma 3 segments
tPid = sum(isCSL3(grains.triplePoints.boundaryId),2) >= 2;

% report and plot the selected triple points
numberOfSelectedTriplePoints = nnz(tPid)

hold on
plot(grains.triplePoints(tPid),'color','red','linewidth',2,...
  'MarkerSize',8)
hold off

%% What the selected triple points mean
% The map contains 83 such points. Many mark where a twin lamella ends
% against another boundary. Their number is one measure of how strongly
% twinned a material is, although it does not describe network
% connectivity by itself.

%% Merge across the twins
%
% A twin belongs to the grain in which it grew. Passing the selected
% segments to <grain2d.merge.html |merge|> dissolves those interfaces and
% groups the grains on their two sides. See <GrainMerge.html Merging
% Grains> for the bookkeeping after this operation.

% merge grains that share a selected Sigma 3 segment
[mergedGrains,parentIds] = merge(grains,gB3);

% report the number of grains before and after merging
numberOfGrainsBeforeAndAfter = [length(grains),length(mergedGrains)]

% overlay the merged-grain boundaries on the previous plot
hold on
plot(mergedGrains.boundary,'linecolor','w','linewidth',3)
hold off

%% What merging changes
% The merge reduces 885 reconstructed grains to 415 groups. Many white
% outlines enclose several coloured grains; those regions were one grain
% before it twinned.
%
% Merging records which grains belong together, but it does not identify
% which child was the original grain. That distinction needs an additional
% rule, as explained on the merging page.

%% Compare other low Sigma relationships
%
% Other low $\Sigma$ boundaries can be selected in the same way. This
% comparison deliberately uses the wider fixed tolerance of 5 degrees for
% every relationship.

delta = 5*degree;
gB5 = gB(gB.isTwinning(CSL(5,ebsd.CS),delta));
gB7 = gB(gB.isTwinning(CSL(7,ebsd.CS),delta));
gB9 = gB(gB.isTwinning(CSL(9,ebsd.CS),delta));
gB11 = gB(gB.isTwinning(CSL(11,ebsd.CS),delta));

lowSigmaSegmentCounts = [length(gB5),length(gB7),...
  length(gB9),length(gB11)]

hold on
plot(gB5,'lineColor','b','linewidth',2,'DisplayName','CSL 5')
plot(gB7,'lineColor','g','linewidth',2,'DisplayName','CSL 7')
plot(gB9,'lineColor','m','linewidth',2,'DisplayName','CSL 9')
plot(gB11,'lineColor','c','linewidth',2,'DisplayName','CSL 11')
hold off

%% What the other relationships contribute
% In the order $\Sigma 5$, $\Sigma 7$, $\Sigma 9$, and $\Sigma 11$, the
% output gives 26, 41, 504, and 187 segments. Thus, $\Sigma 9$ and
% $\Sigma 11$ account for 2.9 and 1.1 percent of the network, while
% $\Sigma 5$ and $\Sigma 7$ together contribute fewer than 70 segments.
%
% These colours occur mainly in short pieces rather than along complete
% boundaries. The prominence of $\Sigma 9$ is not accidental: when two
% different $\Sigma 3$ twin variants meet, their composition can be a
% $\Sigma 9$ relationship.

%% The misorientations in their fundamental region
%
% The preceding tests compare each segment with one ideal relationship.
% A complementary view plots all boundary misorientations in the
% symmetry-reduced fundamental region. Grain-exchange symmetry identifies
% a misorientation with its inverse because a boundary has no preferred
% side.

% compute and plot the boundary of the fundamental region
oR = fundamentalRegion(ebsd.CS,ebsd.CS,'antipodal');
close all
plot(oR)

% plot a reproducible sample of 500 boundary misorientations
rng default;
mori = discreteSample(gB.misorientation,500);
hold on
plot(mori.project2FundamentalRegion)

% mark the ideal Sigma 3 misorientation
plot(csl3.project2FundamentalRegion('antipodal'),...
  'MarkerColor','r','DisplayName','CSL 3','MarkerSize',20)
hold off

%% What the fundamental-region plot shows
% The cloud is not uniform. It forms a dense clump at a corner of the
% region, and the red $\Sigma 3$ marker lies inside that clump.

%% Estimate the boundary misorientation distribution
%
% A density estimated from the segment misorientations makes the same
% observation quantitative. The |halfwidth| is the angular smoothing
% scale, while |bandwidth| sets the harmonic truncation. The displayed
% summary confirms that the MDF retains grain-exchange symmetry.
%
% This is a boundary, or correlated, MDF. It contains one sample per
% segment, so long or finely sampled boundaries contribute more than short
% ones. <MisorientationDistributionFunction.html Misorientation
% Distribution Function> compares this population with the uncorrelated
% MDF implied by texture alone.

mdf = calcDensity(gB.misorientation,'halfwidth',5*degree,...
  'bandwidth',48)

%% Plot axis--angle sections
%
% Sections at constant misorientation angle show where the density lies.
% The low $\Sigma$ relationships are annotated for comparison.

plot(mdf,'axisAngle',(25:5:60)*degree,'colorRange',[0 15])

annotate(CSL(3,ebsd.CS),'label','$CSL_3$','backgroundcolor','w')
annotate(CSL(5,ebsd.CS),'label','$CSL_5$','backgroundcolor','w')
annotate(CSL(7,ebsd.CS),'label','$CSL_7$','backgroundcolor','w')
annotate(CSL(9,ebsd.CS),'label','$CSL_9$','backgroundcolor','w')

drawNow(gcm)

%% Locate the density maximum
% The density is concentrated in the 60 degree section at the
% $\Sigma 3$ label. The two strongest local maxima provide a numerical
% check.

[peakMRD,peakMori] = max(mdf,'numLocal',2);

peakMRD

peakAngles = angle(peakMori) ./ degree

peakAxes = round(axis(peakMori))

%% Read the strongest maximum
% The first maximum is 54.2 multiples of a random distribution (mrd), at
% 60.0 degrees about a member of the $\langle 111 \rangle$ family. It is
% the $\Sigma 3$ twin relationship.

%% Count segments near an ideal relationship directly
%
% <orientation.volume.html |volume|> gives the fraction of sampled segment
% misorientations within a chosen radius. It does not require an MDF.

sigma3WithinTwoDegrees = 100 * ...
  volume(gB.misorientation,csl3,2*degree)

sigma9WithinTwoDegrees = 100 * ...
  volume(gB.misorientation,CSL(9,ebsd.CS),2*degree)

%% Compare the direct segment fractions
% Within 2 degrees, 40.76 percent of the segments are $\Sigma 3$, compared
% with 2.07 percent for $\Sigma 9$. These are segment fractions, not equal
% votes from neighbouring grain pairs.

%% Evaluate the MDF along low-index axes
%
% The density can also be evaluated along paths through misorientation
% space. The three paths below are rotations about low-index axes.
% The $\Sigma 3$ relationship is a 60 degree rotation about
% $\langle 111 \rangle$.

omega = linspace(0,60*degree);
fibre100 = orientation.byAxisAngle(xvector,omega,mdf.CS,mdf.SS);
fibre111 = orientation.byAxisAngle(vector3d(1,1,1),omega,mdf.CS,mdf.SS);
fibre101 = orientation.byAxisAngle(vector3d(1,0,1),omega,mdf.CS,mdf.SS);

close all
plot(omega ./ degree,mdf.eval(fibre100),'LineWidth',2)
hold on
plot(omega ./ degree,mdf.eval(fibre111),'LineWidth',2)
plot(omega ./ degree,mdf.eval(fibre101),'LineWidth',2)
hold off
legend('[100]','[111]','[101]')
xlabel('misorientation angle');
ylabel('mrd');

%% Read the low-index-axis profiles
% The [111] curve rises to a sharp peak of 54.2 mrd at 60 degrees. The
% [101] curve stays below 3.4 mrd, and the [100] curve stays below 1 mrd.
% One misorientation dominates this material, and it is the twin.

%% Evaluate the MDF at one misorientation
%
% Finally, the MDF can be evaluated at a single misorientation. This asks
% how common that particular relationship is in this boundary network.

testMori = orientation.byEuler(15*degree,28*degree,14*degree,...
  mdf.CS,mdf.CS);

testMisorientationMRD = mdf.eval(testMori)

sigma3MRD = mdf.eval(csl3)

%% Compare the two density values
% The chosen misorientation has density 1.55 mrd, close to the random
% baseline. The $\Sigma 3$ relationship has density 54.2 mrd, about 54
% times the random baseline.

%% References
%
% * H. Grimmer, W. Bollmann, and D. H. Warrington,
% <https://doi.org/10.1107/S056773947400043X Coincidence-site lattices and
% complete pattern-shift lattices in cubic crystals>, _Acta
% Crystallographica A_ 30 (1974), 197--207, defines the cubic CSL and
% establishes the meaning of $\Sigma$.
% * D. G. Brandon,
% <https://doi.org/10.1016/0001-6160(66)90168-4 The structure of high-angle
% grain boundaries>, _Acta Metallurgica_ 14 (1966), 1479--1484,
% introduces the angular tolerance used above.
% * V. Randle,
% <https://doi.org/10.1016/S1044-5803(02)00193-6 The coincidence site
% lattice and the sigma enigma>, _Materials Characterization_ 47 (2001),
% 411--416, explains why a CSL label alone does not establish special
% behaviour.
% * G. S. Rohrer,
% <https://doi.org/10.1007/s10853-011-5677-3 Grain boundary energy
% anisotropy: a review>, _Journal of Materials Science_ 46 (2011),
% 5881--5895, reviews the dominant role of boundary-plane orientation.
% * A. P. Sutton and R. W. Balluffi,
% <https://search.worldcat.org/title/31166519 Interfaces in Crystalline
% Materials>, Clarendon Press, 1995, is the standard textbook treatment of
% interface crystallography, structure, thermodynamics, and kinetics.

%% Next
%
% Continue with <TwinningBoundaries.html Twinning Analysis> to infer an
% unknown twin relationship from measured boundaries. The chapter next
% turns from crystallographic character to geometry in
% <BoundaryCurvature.html Boundary Curvature>. Use <GrainMerge.html Merging
% Grains> when the merged parent--child bookkeeping matters.

%#ok<*ASGLU,*NOPTS>
