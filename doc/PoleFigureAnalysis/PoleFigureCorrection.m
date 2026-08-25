%% Data Correction
%
%%
% Diffraction counts are not pole densities. Between the two lie the
% background radiation the detector also sees, the defocusing that reduces
% the count as the specimen is tilted, the odd outlier, and a scale factor
% nobody measured. This page is about the operations that turn the one into
% the other.
%
% Pole figures behave like arrays of numbers throughout: they add, they
% subtract, they can be indexed and assigned to.

specimenFrame.rolling.makeDefault
mtexdata geesthacht

% plot imported pole figure
plot(pf)

%% Splitting and reordering
%
% This file holds four pole figures, and they are not four measurements of
% the same kind. The first and third are the complete measurements, on 679
% specimen directions each; the second and fourth hold 16 points apiece and
% are background measurements belonging to them. Selecting is done with
% braces, one index per pole figure.

pf_complete = pf({1,3})
pf_background= pf({2,4})

%%
% Arithmetic works as it does on numbers, which is what makes a background
% subtraction expressible at all. A weighted superposition of the first and
% third pole figures, for instance:

2*pf({1}) + 3*pf({3})

%% Background and defocusing
%
% <PoleFigure.correct.html |correct|> does the two standard corrections. The
% background measurement is subtracted, interpolated over the directions it
% was not measured at, and a defocusing curve may be supplied the same way.

pf = correct(pf_complete,'background',pf_background);
plot(pf)

%%
% The corrected intensities run from 7 to 631 with a mean of 273. Still
% counts, not densities - what is missing is the scale.

%% Normalization
%
% A pole density is measured in multiples of a random distribution, so its
% mean over the sphere must be 1. For a complete pole figure that is a
% division by the mean, and <PoleFigure.normalize.html |normalize|> does it.

pf_normalized = normalize(pf);
plot(pf_normalized)

%%
% Now the values run from 0.03 to 2.15 about a mean of 1, and they can be
% compared with any other measurement of any other specimen.
%
% An incomplete pole figure cannot be normalized this way: the part of the
% sphere that was not measured also carries density, and how much is exactly
% what is unknown. The way round it is to reconstruct an ODF first, which
% fills in the missing part, and normalize against that.

% compute an ODF from the pole figure data
odf = calcODF(pf);

% and use it for normalization
pf_normalized = normalize(pf,odf);

plot(pf_normalized)

%%
% These pole figures are complete, so the two normalizations agree to within
% a percent. On incomplete data they would not.

%% Outliers
%
% A single bad measurement can distort a reconstruction, since the solver
% has no reason to distrust it. <PoleFigure.isOutlier.html |isOutlier|>
% marks the points that disagree with their neighbourhood.
%
% To have something to find, we first spoil a hundred random measurements.

rng(0) % make the example reproducible

% Let us add 100 random outliers to the pole figure data
% First we select 100 random positions within the pole figures
ind = randperm(pf.length,100);

% Next we multiply the intensity at these positions by a random value
% between 3 and 4
factor = 3+rand(100,1);
pf(ind).intensities = pf(ind).intensities(:) .* factor;

% Let's check the result
plot(pf)

%%
% The spoiled points stand out as isolated bright dots. Deleting them is an
% assignment of the empty matrix, as with any MATLAB array.

% check for outliers
condition = pf.isOutlier;

% remove outliers
pf(condition) = [];

% plot the corrected pole figures
plot(pf)

%%
% 55 of the 100 are gone. The detection compares each point with its
% neighbourhood, so an outlier sitting next to another one raises the local
% level and hides behind it - running the test a second time catches 26
% more.

pf(pf.isOutlier) = [];
plot(pf)

%% Any other condition
%
% Nothing about this is specific to outliers. A condition on the intensities
% selects points, and points can be deleted or overwritten. Capping the
% counts at 500 affects 94 of the remaining 1277 measurements:

% find those values
condition = pf.intensities > 500;

% cap the values in the pole figures
pf(condition).intensities = 500;

plot(pf)

%% Rotating pole figures
%
% If the specimen frame of the measurement is not the one the analysis
% should be in, the pole figures can be rotated - see
% <PoleFigureImport.html Import> for getting the frame right in the first
% place, which is the better cure.

% This defines a rotation around the x-axis about 100 degree
rot = rotation.byAxisAngle(xvector,100*degree);

%%
% <PoleFigure.rotate.html |rotate|> applies it to the measured directions,
% leaving the intensities untouched.

pf_rotated = rotate(pf,rot);
plot(pf_rotated,'antipodal')

%%
% The rotation tips the measured cap across the equator, and |'antipodal'|
% folds the part that went below back into the same disc. The blank band
% left in each figure is the part of the sphere that was never measured, now
% turned into the middle of the plot - which is a good illustration of why a
% rotation that could have been avoided is best avoided.
