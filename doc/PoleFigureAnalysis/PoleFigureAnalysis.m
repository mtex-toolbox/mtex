%% Pole Figures
%
%%
% Diffraction pole figures describe crystallographic texture without locating
% individual crystals. A pole figure is the distribution of normals to one
% family of lattice planes over directions in the specimen reference frame.
%
% An X-ray or neutron experiment first records diffraction intensity. After
% background and defocusing corrections and normalization, that intensity is
% a quantitative pole density. Keeping these two stages separate prevents raw
% counts from being mistaken for multiples of a random distribution (mrd).
%
% Diffraction averages all illuminated crystals at once. It can probe a bulk
% volume without a vacuum or a conductive sample, and it often counts many
% more crystals than an orientation map. The price is spatial information: a
% pole figure says which orientations occur, not where they occur.
%
% This chapter assumes the Miller-index notation introduced in
% <CrystalDirections.html Miller Indices>. Before reconstructing an
% orientation distribution function (ODF), review its definition and units in
% <ODFTheory.html ODF Theory>.

plottingConvention.default('y↑→x');
mtexdata dubna silent

pf

%%
% The summary lists seven measured pole figures from one quartz specimen.
% One entry contains two lattice planes because their diffraction peaks were
% too close to separate. Its intensity is the weighted sum of both pole
% figures, so the reconstruction must include both planes and their
% coefficients rather than treating the entry as a single reflection.
%
% The plotting convention draws specimen Y upwards and specimen X to the
% right. It changes the screen layout, not the specimen reference frame or the
% measured directions.

plot(pf,'figSize','small')

%%
% Notice that the bands and maxima occupy different specimen directions in
% different panels. Each lattice-plane family therefore supplies a different
% projection of the same texture, and the projections constrain one another.
% Superposed reflections are common measurements rather than errors; the
% two-plane title identifies the one in this data set.
%
%% What one pole-figure value means
%
% An ODF is a density over the three-dimensional space of orientations. For a
% lattice-plane normal $h$ and a specimen direction $r$, one pole-figure value
% sums the ODF over every orientation that maps $h$ onto $r$.
%
% Those orientations form a one-dimensional fibre in orientation space. The
% integral along that fibre is the pole-figure transform of the ODF, also
% called its Radon transform. <ODFPoleFigure.html Pole Figures of an ODF>
% develops this forward projection, while <S2FunRadon.html The Spherical Radon
% Transform> introduces the underlying operation on the sphere.
%
% A pole figure is therefore a two-dimensional projection of a
% three-dimensional distribution. Measuring several lattice-plane families
% reduces the ambiguity caused by having too few projections, but the inverse
% problem still does not have a unique answer.
%
%% What ordinary diffraction cannot determine
%
% Under Friedel's law, ordinary diffraction cannot distinguish the two sides
% of a lattice plane. Its pole figures are antipodally symmetric even when the
% material's orientation distribution is not. In a harmonic expansion, the
% measurements determine the even-degree terms of the ODF but not the
% odd-degree terms.
%
% Anomalous-scattering experiments can break this equivalence, but additional
% conventional pole figures cannot. This is a different limitation from
% measuring too few lattice-plane families, so the two should not be confused.
%
% A reconstruction must choose the missing odd part by an assumption.
% Different choices can weaken real components, raise the uniform background,
% or create spurious peaks where the material has none. These inversion
% artefacts are called *ghosts*.
%
% Ghost correction makes that choice more defensible, but it does not turn an
% assumption into measured information. A close match between measured and
% recalculated pole figures is necessary validation; it is not proof that the
% reconstructed ODF is unique or correct.
%
%% Recommended reading order
%
% Start with <PoleFigureImport.html Import> and <PoleFigurePlot.html Plot> to
% bring measured data into MTEX and inspect it. Continue with
% <PoleFigureCorrection.html Modify> for background subtraction, defocusing,
% normalization, incomplete coverage, outliers, and justified rotations.
%
% <PoleFigure2ODF.html ODF Reconstruction> develops the direct inversion, and
% <PoleFigureRefinement.html Iterative ODF Reconstruction> changes its
% representation scale or measurement density. The latter assumes the direct
% workflow and cannot remove its non-uniqueness.
%
% <PoleFigureSimulation.html Simulation> then runs the forward and inverse
% problems with a known ODF. It also assumes <ODFModeling.html ODF Modelling>
% and <ODFPoleFigure.html Pole Figures of an ODF>. This controlled experiment
% is the most reliable way to see what a reconstruction preserves.
%
% Next read <PoleFigure2ODFAmbiguity.html The Ghost Effect> and
% <PoleFigure2ODFGhostCorrection.html Ghost Correction>. They separate the
% limitations caused by too few pole figures from information that ordinary
% diffraction never measured.
%
% <PoleFigureSantaFe.html Santa Fe Example> tests the choices on a standard
% model whose true ODF is known. <PoleFigureDubna.html Dubna Example> applies
% the validation sequence to measured neutron data, where no true ODF is
% available. <PoleFigureExport.html Export> closes the route by exchanging
% measured or recalculated pole figures with other software.
%
%% Further reading
%
% * H.-J. Bunge,
% <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis in Materials
% Science: Mathematical Methods>, Butterworths, English ed., 1982. This is
% the classical textbook treatment of pole figures and ODF reconstruction.
% * ASTM International,
% <https://doi.org/10.1520/E0081-96R24 ASTM E81-96(2024): Standard Test Method
% for Preparing Quantitative Pole Figures>. It covers experimental procedures
% for complete and partial quantitative X-ray pole figures.
% * D. Chateigner, L. Lutterotti and M. Morales,
% <https://doi.org/10.1107/97809553602060000968 Quantitative texture analysis
% and combined analysis>, _International Tables for Crystallography_, Volume
% H, chapter 5.3, 2019. It connects diffraction intensity, corrections,
% normalized pole density and the fundamental equation of texture analysis.
% * H.-J. Bunge and C. Esling,
% <https://doi.org/10.1107/S0021889881009308 Determination of the odd part of
% the texture function by anomalous scattering>, _Journal of Applied
% Crystallography_ 14, 253--255, 1981. It explains the experimental exception
% to the ordinary Friedel limitation.
% * R. Hielscher and H. Schaeben,
% <https://doi.org/10.1107/S0021889808030112 A novel pole figure inversion
% method: specification of the MTEX algorithm>, _Journal of Applied
% Crystallography_ 41, 1024--1037, 2008. It specifies the estimator and
% numerical reconstruction used by MTEX.
%
%% Next
%
% A reconstructed ODF can be explored with <ODFAnalysis.html ODF Analysis>.
% In the main documentation route that chapter supplies the theory used here;
% the next measurement chapter is <EBSDAnalysis.html EBSD Analysis>. EBSD
% assigns orientations point by point on a polished surface and retains the
% spatial information that a bulk diffraction pole figure averages away.
%
% <SphericalFunctions.html Spherical Functions> and
% <SO3Functions.html Orientation Functions> develop the mathematical function
% spaces behind pole figures and ODFs.
