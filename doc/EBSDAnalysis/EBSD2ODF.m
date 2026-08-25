%% ODF Estimation from EBSD data
%
%%
% A map holds a finite list of orientations; an orientation distribution
% function is a density over the whole of orientation space. Getting from
% one to the other means spreading each measurement out a little and adding
% the results up, and the only real question is how far to spread it. Too
% little and the estimate is a set of spikes, one per measurement; too much
% and every feature is washed out.
%
% The example is a copper map.

plottingConvention.default('y↑→x');
mtexdata copper

plot(ebsd,ebsd.orientations)

%%
% <rotation.calcDensity.html |calcDensity|> does the estimation.

odf = calcDensity(ebsd('copper').orientations)

plotSection(odf,'contourf')
mtexColorMap LaboTeX
mtexColorbar

%%
% The result is a density over orientation space, shown here in sections,
% with a maximum of 3.7 times uniform. The method is kernel density
% estimation, a generalized histogram, and the closing section writes it
% down.
%
% If nothing is said about the spread, a halfwidth of 10 degrees is used.
% That default is a guess, and it is worth replacing.
%
%% Automatic halfwidth selection
%
% <orientation.calcKernel.html |calcKernel|> estimates a halfwidth from the
% data. It assumes the orientations are statistically independent, which is
% exactly what the measurements of an EBSD map are not: neighbouring pixels
% of one grain are not independent observations, they are the same grain
% measured many times.

% try to compute an optimal kernel
psi = calcKernel(ebsd.orientations)

%%
% It returns 2.7 degrees, which is too small - it is fitting the scatter
% within grains rather than the spread between them. Reconstructing the
% grains and using their mean orientations gives one observation per grain,
% 368 of them instead of 16184 pixels, and a halfwidth of 4.7 degrees. That
% kernel is the one to estimate with.

% grains reconstruction
grains = calcGrains(ebsd,'minPixel',5);

% compute optimal halfwidth from the meanorientation of grains
psi = calcKernel(grains('co').meanOrientation)

% compute the ODF with the kernel psi
odf = calcDensity(ebsd('co').orientations,'kernel',psi)

%%
% The same measurements now give a maximum of 23 times uniform instead of
% 3.7. Nothing about the specimen changed - the default halfwidth had been
% smearing the texture over twice the width it needed.
%
% From here the ODF is an ordinary function on orientation space and
% everything in <ODFCharacteristics.html ODF Characteristics> and
% <ODFPlot.html ODF Plots> applies to it - pole figures, for instance.

h = [Miller(1,0,0,odf.CS),Miller(1,1,0,odf.CS),Miller(1,1,1,odf.CS)];
plotPDF(odf,h,'antipodal','silent')

%% How much the halfwidth matters
%
% A numerical experiment settles the question, since it is one of the rare
% cases where the true answer is known: sample orientations from an ODF
% that was written down, estimate an ODF back from the sample, and compare.

modelODF = fibreODF(Miller(1,1,1,crystalSymmetry('cubic')),xvector);
ori = discreteSample(modelODF,10000)

%%
% Six halfwidths, each a factor of two apart,

hw = [1*degree, 2*degree, 4*degree, 8*degree, 16*degree, 32*degree];

%%
% and for each of them an estimate and its distance from the ODF it came
% from.

e = zeros(size(hw));
for i = 1:length(hw)

  odf = calcDensity(ori,'halfwidth',hw(i),'silent');
  e(i) = calcError(modelODF, odf);

end

%%
% The error is large at both ends and has a clear minimum in between.

close all
plot(hw/degree,e)
xlabel('halfwidth in degree')
ylabel('estimation error')

%%
% For these 10000 orientations the minimum is at 8 degrees, with an error
% of about 0.05 - roughly a seventh of what 1 degree or 16 degrees produce.
% The best halfwidth is not a property of the phase or of the method; it
% depends on how many independent orientations there are, and it shrinks as
% that number grows.
%
%% The definition
%
% For a radially symmetric, unimodal model ODF $\psi : SO(3) \to R$ - the
% *kernel* - and individual orientations $o_1,o_2,\ldots,o_M$, the kernel
% density estimator is
%
% $$f(o) = \frac{1}{M} \sum_{i=1}^{M} \psi(o o_i^{-1})$$
%
% Each measurement contributes one copy of $\psi$ centred on itself, and
% the halfwidth of $\psi$ is the spread this page is about. The kernels
% MTEX offers are described in
% <SO3Kernels.html Kernel Functions on SO(3)>.
%
%#ok<*NASGU>
