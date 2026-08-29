%% Exporting Grains
%%
%
% A grain combines several kinds of information: an identity, scalar
% properties, a mean orientation, an outline, and a place in the boundary
% network. No single exchange format on this page preserves all of them.
% Choose the representation that the receiving program needs, and record
% the information required to interpret it.
%
% This page assumes that grains have already been reconstructed as in
% <GrainReconstruction.html Grain Reconstruction>. The examples use the
% Forsterite data set. Exporting a picture instead of the underlying data is
% covered in <PlottingExport.html Exporting Plots>.

plottingConvention.default('y↑→x');
mtexdata forsterite silent

grainsRaw = calcGrains(ebsd('indexed'),'angle',10*degree);

% remove grains with ten or fewer measurements
grainsRaw = grainsRaw(grainsRaw.numPixel > 10)

%% Record how the grains were made
%
% The displayed summary identifies the phases and the number of grains that
% will be exported. The cutoff above and the 10 degree reconstruction
% threshold are also part of the result. Record them with the source map,
% the MTEX version, and any other processing choices.
%
% Smoothing changes polygon coordinates, areas, perimeters, and segment
% lengths. It does not change grain IDs, pixel counts, or mean orientations.
% We therefore keep |grainsRaw| for measurement-level boundary data and use
% a smoothed copy for shape data.

grains = smoothBoundary(grainsRaw,5);

%% Export a grain table
%
% A MATLAB <matlab:doc('table') |table|> collects one row per grain.
% <matlab:doc('writetable') |writetable|> can then write the rows to CSV for
% a spreadsheet or a statistics package.
%
% A grain ID is a persistent label, not the row number in a subset. The
% distinction is demonstrated in <SelectingGrains.html Selecting Grains>.
% The |phase| property is the numeric phase value imported with the map, so
% the readable mineral name is exported as a separate column.
% A grain with no data on one side of it has truncated geometry. The
% |isBoundary| column lets the receiver identify those grains instead of
% silently treating their visible area and perimeter as complete.
% Called with one argument, |isBoundary| flags every grain that owns a
% segment with no grain on the other side. That covers the grains at the map
% edge and the grains around an unindexed region inside the map.
% Passing the map as a second argument flags only the grains at its extent.
%
% Lengths are in the map's measurement unit and areas in its square. This
% map uses micrometres, so the unit is included in each relevant column
% name. <ShapeParameters.html Shape Parameters> defines these quantities.
% Any other scalar grain property can be appended in the same way.

mineralList = grains.mineralList;
mineral = reshape(string(mineralList(grains.phaseId)),[],1);

T = table(grains.id, grains.phase, mineral, grains.isBoundary, ...
  grains.numPixel, grains.area, grains.perimeter, ...
  grains.equivalentRadius, grains.GOS./degree, ...
  'VariableNames',{'id','phase','mineral','isBoundary','numPixel',...
  'area_um2','perimeter_um','equivalentRadius_um','GOS_degree'});

head(T)

%% Add mean orientations
%
% An orientation row needs one crystal symmetry. We therefore restrict the
% table and both grain lists to Forsterite before adding Euler angles.
% Naming the Bunge convention and degree in the headings removes two common
% ambiguities.

grains = grains('Forsterite');
grainsRaw = grainsRaw('Forsterite');
T = T(T.mineral == "Forsterite",:);

[phi1,Phi,phi2] = grains.meanOrientation.Euler('Bunge');

T.phi1_Bunge_degree = phi1./degree;
T.Phi_Bunge_degree = Phi./degree;
T.phi2_Bunge_degree = phi2./degree;

csvFile = fullfile(tempdir,'grains.csv');
writetable(T,csvFile);

head(readtable(csvFile))

%%
% The reloaded rows retain their values and descriptive headings. Adding
% the orientation columns makes the table self-contained only when the
% receiving program also knows the Forsterite crystal symmetry and the
% crystal and specimen reference frames. A reference frame is the frame in
% which the data are expressed.
%
% A CSV file has no standard place for this context. Accompany it with a
% README or structured metadata that records the source, phase symmetries,
% spatial and angular units, Euler convention, reference frames,
% reconstruction threshold, size cutoff, and boundary smoothing.

%% Export mean orientations
%
% When only the orientations are needed,
% <quaternion.export.html |export|> writes a compact ASCII table. Its
% conventions and limitations are described in
% <OrientationExport.html Exporting Crystal Orientations>.

orientationFile = fullfile(tempdir,'grainOrientations.txt');
export(grains.meanOrientation,orientationFile,'Bunge');

fid = fopen(orientationFile);
for k = 1:3, disp(fgetl(fid)); end
fclose(fid);

%%
% The first line identifies the three Euler columns, and the following rows
% contain Bunge angles in degree. Crystal symmetry and reference frames are
% not stored in this file.
%
% A struct appends one column per field. Every field must have one value per
% orientation, so grain properties remain aligned with their mean
% orientations.

S.area_um2 = grains.area;
S.GOS_degree = grains.GOS ./ degree;

export(grains.meanOrientation,orientationFile,S,'Bunge');

fid = fopen(orientationFile);
for k = 1:3, disp(fgetl(fid)); end
fclose(fid);

%% Export a VPSC texture
%
% <orientation.export_VPSC.html |export_VPSC|> writes the weighted texture
% format used by the VPSC crystal-plasticity code. It accepts Bunge, Kocks,
% or Roe Euler angles and normalises the supplied weights to sum to one.
%
% Here the weights are observed areas on a two-dimensional section. Treating
% those area fractions as three-dimensional volume fractions is a modelling
% assumption, not a conversion performed by MTEX.

vpscFile = fullfile(tempdir,'grains.tex');
export_VPSC(grains.meanOrientation,vpscFile,'Bunge',...
  'weights',grains.area);

vpscData = readmatrix(vpscFile,'FileType','text','NumHeaderLines',4);
writtenWeightSum = sum(vpscData(:,4))

%%
% The printed sum is one to the precision stored in the text file. The VPSC
% header also records the Euler convention and number of orientations, but
% the phase symmetry and reference frames still need companion metadata.

%% Export polygon geometry
%
% Each grain outline is stored as one or more closed loops. The property
% |grains.poly| contains vertex indices in walk order. These indices refer
% to |grains.allV|, the complete vertex list. They do not index |grains.V|,
% which is a shorter list containing only the vertices used by the current
% grain subset.
%
% A grain that encloses another grain has an outer loop followed by one or
% more inner loops. This is the same enclosure described from the outside
% as a hole and from the inside as an inclusion. Each loop repeats its first
% vertex at the end.

V = grains.allV;
firstInterior = find(~grains.isBoundary,1);
poly = grains(firstInterior).poly{1};
polyVertexCount = numel(poly)

xy = [V(poly).x, V(poly).y];
xy(1:5,:)

newMtexFigure('figSize','small');
plot(grains(firstInterior),'FaceColor','LightSkyBlue','micronbar','off');
hold on
plot(xy(:,1),xy(:,2),'k.','MarkerSize',12);
hold off

%%
% The blue area is the first grain that does not touch the map edge. The
% black markers trace the vertex walk that will be written, including the
% repeated endpoint that closes the loop. These are smoothed coordinates,
% not the original pixel staircase.
%
% The following file contains every loop of every Forsterite grain. Both
% |grainId| and |loopId| are needed: a grain ID groups loops into grains,
% while a loop ID keeps an outer outline separate from enclosure outlines.

polygonFile = fullfile(tempdir,'grainPolygons.txt');
fid = fopen(polygonFile,'w');
fprintf(fid,'%% grainId loopId x_um y_um\n');
for k = 1:length(grains)
  p = grains(k).poly{1};
  loopStart = 1;
  loopId = 1;
  while loopStart < numel(p)
    loopEnd = loopStart + find(p(loopStart+1:end) == p(loopStart),1);
    q = p(loopStart:loopEnd);
    fprintf(fid,'%d %d %.17g %.17g\n',...
      [repmat(double(grains.id(k)),1,numel(q)); ...
      repmat(loopId,1,numel(q)); V(q).x.'; V(q).y.']);
    loopStart = loopEnd + 1;
    loopId = loopId + 1;
  end
end
fclose(fid);

fid = fopen(polygonFile);
for k = 1:4, disp(fgetl(fid)); end
fclose(fid);

%% Export the boundary network
%
% A grain boundary is a segment between two neighbouring EBSD measurements
% that belong to different grains. The boundary table below uses the
% unsmoothed network so each row retains that measurement-level meaning.
% It excludes segments next to grains removed by the size cutoff.

gB = grainsRaw.boundary('Forsterite','Forsterite');
gB = gB(all(ismember(gB.grainId,grainsRaw.id),2));

TB = table(gB.grainId(:,1),gB.grainId(:,2),gB.segLength,...
  gB.misorientation.angle./degree,...
  'VariableNames',{'grainA','grainB','segLength_um',...
  'segmentDisorientation_degree'});

head(TB)

%%
% <grainBoundary.grainBoundary.html |gB|> stores one row per boundary
% segment. The two IDs identify its neighbouring grains. The angle is the
% disorientation between the adjacent measurements across that segment,
% not the disorientation between the two grain mean orientations. Continue
% with <BoundaryProperties.html Grain Boundary Properties> before exporting
% further segment quantities.

%% Save MTEX objects
%
% If the data will be read by the same MTEX installation, MATLAB |save|
% preserves the complete objects more conveniently than separate text
% tables. Saving the source map with both grain lists keeps the measurements
% available for later checks; the processing history still belongs in the
% companion metadata.

matFile = fullfile(tempdir,'grains.mat');
save(matFile,'grains','grainsRaw','ebsd');

%%
% The MTEX objects inside a |.mat| file are not readable by general
% non-MATLAB software, and they are not guaranteed to load in a future MTEX
% version. For long-term archiving, prefer documented ASCII tables such as
% those above together with the source data and companion metadata. No one
% of these tables replaces the complete MTEX objects.

%%
% Remove the temporary files created by this page.

delete(csvFile);
delete(orientationFile);
delete(vpscFile);
delete(polygonFile);
delete(matFile);

%% Further reading
%
% * <https://www.iso.org/standard/74309.html ISO 13067:2020>, _Microbeam
% analysis - Electron backscatter diffraction - Measurement of average
% grain size_, distinguishes measurements on a two-dimensional section from
% inferences about three-dimensional grain size.
% * H.-J. Bunge,
% <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis in Materials
% Science: Mathematical Methods>, Butterworths, English ed., 1982,
% establishes the Euler-angle convention used in texture analysis.
% * R. A. Lebensohn and C. N. Tomé,
% <https://doi.org/10.1016/0956-7151(93)90130-K A self-consistent anisotropic
% approach for the simulation of plastic deformation and texture development
% of polycrystals>, _Acta Metallurgica et Materialia_ 41 (1993), 2611-2624,
% introduces the VPSC formulation.
% * M. D. Wilkinson et al.,
% <https://doi.org/10.1038/sdata.2016.18 The FAIR Guiding Principles for
% scientific data management and stewardship>, _Scientific Data_ 3 (2016),
% 160018, explains why reusable data need rich metadata and provenance.

%% Next
%
% <NeperInterface.html Neper Interface> follows this page in the chapter and
% constructs synthetic polycrystals for simulation. For measured grain
% boundaries, continue with <GrainBoundaries.html Grain Boundaries>.

%#ok<*NOPTS>
