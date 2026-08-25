%% ODF Import
%
%%
% An ODF file can contain either an exact description of an MTEX function
% or a finite table from which a function has to be reconstructed. MTEX
% supports the following common cases:
%
% * a |.mat| file with an MTEX ODF object - lossless and binary;
% * an MTEX ASCII file containing its components - lossless for the
% supported component representations;
% * a VPSC file containing weighted discrete orientations;
% * a generic text table containing Euler angles and values or weights.
%
% Importing ODF data into MTEX means to create an ODF variable from data
% files containing Euler angles and weights. Once such an variable has been
% created the data can be analyzed and processed in many ways. See e.g.
% <ODFCharacteristics.html ODF Characteristics>. The simplest way to import
% ODF data is the <import_wizard.html import wizard>, started by typing
% |import_wizard| at the command line. It browses a folder, shows what each
% file contains, and either puts the result in a variable or writes the
% import script for it.
%
% Such a generated script looks like this.

% State how specimen x and y are drawn. This does not change the imported
% orientations, but makes the frame explicit when they are inspected.
plottingConvention.default('y↑→x');

% define crystal and specimen symmetry
cs = crystalSymmetry('cubic');

% the file name
fname = [mtexDataPath '/ODF/odf.txt'];

% load the data
odf = SO3Fun.load(fname,'CS',cs,'Bunge',...
  'ColumnNames',{'Euler 1','Euler 2','Euler 3','weights'});

% plot data
plot(odf,'sections',6,'silent')



%% What the weights mean
%
% ASCII files store an ODF as a table of orientations and weights. That
% table is *not* a complete description of a function - it fixes the ODF at
% finitely many points and says nothing in between. Worse, the weight
% column is ambiguous. It may either
%
% # give the value of the ODF at that orientation, or
% # give the volume of a bell shaped component centered there.
%
% MTEX therefore has to be told which of the two is meant, and the answer
% changes the resulting ODF.
%
%% Interpolation
%
% Reading the weights as function values is requested explicitly by the
% flag |'interp'|. MTEX then fits a radial basis function ODF that
% reproduces the tabulated values at the given orientations.

odfInterp = SO3Fun.load(fname,'CS',cs,'Bunge','interp',...
  'ColumnNames',{'Euler 1','Euler 2','Euler 3','weights'});

[norm(odfInterp)^2, max(odfInterp)]

%% Density Estimation
%
% Reading them as component volumes is requested by |'density'|. This is
% <DensityEstimation.html kernel density estimation> and it needs a second
% piece of information that the file does not contain - the halfwidth of
% the bell shaped kernel placed at each orientation.

for hw = [5 10 20]*degree
  odfDens = SO3Fun.load(fname,'CS',cs,'Bunge','density','halfwidth',hw,...
    'ColumnNames',{'Euler 1','Euler 2','Euler 3','weights'});
  fprintf('halfwidth %2d degree : texture index %.3f, maximum %.2f\n',...
    round(hw./degree), norm(odfDens)^2, max(odfDens));
end

%%
% The halfwidth is a genuine free parameter - a wide kernel smears the
% texture out and a narrow one leaves the individual components standing.
% There is no value that can be recovered from the file, so it has to come
% from knowledge about how the data were produced. The section
% <OptimalKernel.html Optimal Kernel Selection> discusses how to choose it
% when the file holds a discrete sample of orientations.

%% When no interpretation is specified
%
% Without either flag, the generic importer uses a heuristic: varying
% weights are interpreted as tabulated values, whereas equal weights are
% treated as a discrete sample for density estimation. This is convenient,
% but it cannot recover the meaning intended by the program that wrote the
% file. Prefer an explicit |'interp'| or |'density'| in a reusable script.
%
% Finally, verify more than successful parsing. Check the Euler-angle
% convention and units, crystal and specimen symmetry, specimen axes and
% the meaning of the weights. The mean ODF should normally be one, and pole
% figures, sections and important peak locations should agree with the
% source. A plausible plot is not enough to distinguish a swapped axis from
% a genuinely different texture.
%
