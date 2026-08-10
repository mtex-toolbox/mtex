%% Exporting Grains
%%
%
% Grains are geometry and data at the same time, and consequently there is
% no single file format that captures all of them. What one wants to export
% is usually one of three things - the grain wise table of properties, the
% mean orientations, or the polygons that make up the grain boundaries.
% This page shows all three. Exporting the picture rather than the numbers
% is covered in <PlottingExport.html Exporting Plots>.
%
% Throughout this page we work with the Forsterite data set.

mtexdata forsterite silent

grains = calcGrains(ebsd('indexed'),'angle',10*degree);
grains = smoothBoundary(grains,5);

% remove the very small grains
grains = grains(grains.numPixel > 10)

%% The grain table
%
% Every scalar grain property can be collected into a MATLAB
% <matlab:doc('table') |table|> and written by |writetable| to a
% spreadsheet or a csv file. This is the most useful format for further
% statistical analysis outside of MTEX.

T = table(grains.id, grains.phase, grains.numPixel, grains.area, ...
  grains.perimeter, grains.equivalentRadius, grains.GOS./degree, ...
  'VariableNames',{'id','phase','numPixel','area','perimeter',...
  'equivalentRadius','GOS'});

head(T)

%%
% Adding the mean orientation as three Euler angle columns makes the table
% self contained. Since Euler angles only make sense within one crystal
% symmetry we restrict ourselves to the Forsterite grains from here on.

grains = grains('Forsterite');
T = T(T.phase == grains.phase(1),:);

[phi1,Phi,phi2] = grains.meanOrientation.Euler;

T.phi1 = phi1./degree;
T.Phi  = Phi./degree;
T.phi2 = phi2./degree;

% we write into the temporary folder to not pollute the MTEX folder
fname = fullfile(tempdir,'grains.csv');
writetable(T,fname)

%%
% and reading it back is a one liner

head(readtable(fname))

%% Mean orientations
%
% If only the orientations are of interest, the command
% <quaternion.export.html |export|> is more convenient, since it knows
% about the Euler angle conventions. It is described in detail in
% <OrientationExport.html Exporting Crystal Orientations>.

export(grains.meanOrientation,fullfile(tempdir,'grainOri.txt'))

%%
% |export| also takes a struct of additional columns, which is the natural
% place for the grain properties that belong to each orientation

S.area = grains.area;
S.GOS = grains.GOS ./ degree;

export(grains.meanOrientation,fullfile(tempdir,'grainOri.txt'),S)

fid = fopen(fullfile(tempdir,'grainOri.txt'));
for k = 1:3, disp(fgetl(fid)); end
fclose(fid);

%%
% For crystal plasticity codes the command
% <orientation.export_VPSC.html |export_VPSC|> writes the VPSC texture
% format, with the grain areas as weights

export_VPSC(grains.meanOrientation,...
  fullfile(tempdir,'grains.tex'),'weights',grains.area)

%% The grain geometry
%
% The outline of a grain is a closed polygon. The property |grains.poly|
% holds, for each grain, the list of vertex indices that walks around it.
% These indices refer to |grains.allV|, the complete vertex list - not to
% |grains.V|, which is the shorter list of vertices actually in use.

V = grains.allV;

poly = grains(1).poly{1};

size(poly)

%%
% Hence the coordinates of the first grain are

xy = [V(poly).x, V(poly).y];

xy(1:5,:)

%%
% Writing all of them into one text file, one grain after the other, is a
% short loop. We use the grain id as a separator so that the file can be
% split up again.

fname = fullfile(tempdir,'grainPolygons.txt');
fid = fopen(fname,'w');
fprintf(fid,'%% grainId x y\n');
for k = 1:min(length(grains),50)
  p = grains(k).poly{1};
  fprintf(fid,'%d %f %f\n',[repmat(double(grains.id(k)),1,numel(p)); ...
    V(p).x.'; V(p).y.']);
end
fclose(fid);

fid = fopen(fname);
for k = 1:4, disp(fgetl(fid)); end
fclose(fid);

%%
% The individual boundary segments, together with the ids of the two grains
% they separate and their misorientation, are reached through
% <grainBoundary.grainBoundary.html |grains.boundary|>

gB = grains.boundary('Forsterite','Forsterite');

TB = table(gB.grainId(:,1), gB.grainId(:,2), gB.segLength, ...
  gB.misorientation.angle./degree, ...
  'VariableNames',{'grainA','grainB','segLength','misAngle'});

head(TB)

%% Saving in MTEX' own format
%
% Finally, if the data is only meant to be read back by MTEX, the ordinary
% MATLAB |save| is both lossless and by far the simplest option

save(fullfile(tempdir,'grains.mat'),'grains','ebsd')

%%
% Note that a |.mat| file is not readable by other software and is not
% guaranteed to load in a future MTEX version - for archiving, prefer one
% of the ASCII formats above.

% clean up
delete(fullfile(tempdir,'grains.csv'))
delete(fullfile(tempdir,'grainOri.txt'))
delete(fullfile(tempdir,'grains.tex'))
delete(fullfile(tempdir,'grainPolygons.txt'))
delete(fullfile(tempdir,'grains.mat'))

%#ok<*NOPTS>
