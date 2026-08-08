%% Spherical Density Estimation
%
%%
% Directional data usually comes as a large list of individual directions -
% think of the c-axes of all the pixels of an EBSD map. Density estimation
% is the process of turning such a discrete list into a continuous function
% on the sphere, the so called density function, which tells us how likely
% it is to observe a direction within a certain region of the sphere.
%
% The general concept of density estimation is explained in the section
% <DensityEstimation.html Density Estimation>. On this page we focus on
% directional data, i.e., on variables of type <vector3d.vector3d.html
% |@vector3d|>, and on the command <vector3d.calcDensity.html
% |calcDensity|>.

plottingConvention.default('y↑→x');

%% The Example Data
%
% Throughout this page we use the c-axes of the Forsterite phase of the
% following EBSD map as our random sample

mtexdata forsterite silent

% the c-axis of each Forsterite pixel
cAxes = ebsd('Fo').orientations * ebsd('Fo').CS.cAxis

%%
% Since we do not want to distinguish between the direction |c| and the
% direction |-c| we consider these vectors as axes and not as directions,
% see <VectorsAxes.html Axes and Antipodal Symmetry>

cAxes.antipodal = true;

%%
% The classical way of visualizing such a data set is a scatter plot in a
% spherical projection

plot(cAxes,'upper','MarkerFaceColor','none',...
  'MarkerEdgeAlpha',0.01,'MarkerSize',4)

%%
% With more than hundred thousand data points such a plot is not very
% conclusive - most of the sphere is covered with markers and it is hard to
% tell where the data are actually concentrated. This is exactly the
% situation where density estimation helps.
%
%% Kernel Density Estimation
%
% The idea of kernel density estimation is to place a bell shaped function
% $\psi$, the so called <S2Kernels.html kernel function>, at each data
% point $\vec v_n$ and to sum up all these shifted kernels
%
% $$ f(\vec v) = \frac{1}{N} \sum_{n=1}^{N} \psi(\vec v \cdot \vec v_n). $$
%
% In MTEX this is done by the command <vector3d.calcDensity.html
% |calcDensity|>

pdf = calcDensity(cAxes)

%%
% The result is a spherical function of type <S2FunHarmonic.S2FunHarmonic.html
% |@S2FunHarmonic|> which we may plot as any other spherical function, see
% <S2FunPlotting.html Plotting Spherical Functions>

plot(pdf,'upper')
mtexColorbar

%%
% Note that the antipodal symmetry of the input data has been passed on to
% the density function. Lets plot the density function and the raw data on
% top of each other

contourf(pdf,'upper')
mtexColorMap LaboTeX

hold on
plot(cAxes,'upper','MarkerFaceColor','none','MarkerEdgeColor','k',...
  'MarkerEdgeAlpha',0.01,'MarkerSize',4)
hold off

%%
% The density function is normalized such that its mean value over the
% sphere is one

mean(pdf)

%%
% Accordingly, the values of the density function are to be read as
% multiples of a uniform distribution (m.u.d.). A value of $3$ means that
% in this region of the sphere we find three times as many c-axes as we
% would expect for randomly distributed axes.
%
%% The Halfwidth
%
% By far the most important parameter of kernel density estimation is the
% halfwidth of the kernel function. It controls how far the influence of a
% single data point reaches and hence how much the estimated function is
% smoothed. In MTEX it is set by the option |'halfwidth'| and defaults to
% $10^{\circ}$.

hw = [2.5 5 10 20] * degree;

mtexFig = newMtexFigure('layout',[1 4]);

for k = 1:length(hw)

  plot(calcDensity(cAxes,'halfwidth',hw(k)),'upper')
  mtexTitle(['$' xnum2str(hw(k)./degree) '^{\circ}$'])

  if k < length(hw), nextAxis; end
end
mtexFig.drawNow

%%
% A too small halfwidth results in a spiky function that mainly reproduces
% the noise of the individual measurements, while a too large halfwidth
% oversmooths the data and may hide relevant details. As a rule of thumb,
% the more data points we have, the smaller the halfwidth may be chosen.
%
% In contrast to the estimation of an orientation density function, cf.
% <OptimalKernel.html Optimal Kernel Selection>, MTEX does not perform an
% automatic halfwidth selection for directional data. It is up to the user
% to choose a reasonable value.
%
% Note how the maximum density decreases with increasing halfwidth. The
% halfwidth also determines the harmonic bandwidth of the resulting
% function - the smaller the halfwidth, the more spherical harmonic
% coefficients are required to represent the density function

for k = 1:length(hw)
  pdfK = calcDensity(cAxes,'halfwidth',hw(k));
  disp(['halfwidth: ' xnum2str(hw(k)./degree) mtexdegchar ...
    ' -> maximum: ' xnum2str(max(pdfK)) ' mud' ...
    ', bandwidth: ' xnum2str(pdfK.bandwidth)])
end

%% Choosing a Different Kernel Function
%
% By default MTEX uses the <S2DeLaValleePoussinKernel.html de la Vallee
% Poussin kernel>. Any other <S2Kernels.html spherical kernel function> may
% be passed by the option |'kernel'|. Lets compare the default kernel with
% the <S2DirichletKernel.html Dirichlet kernel>, which simply truncates the
% harmonic series at a given bandwidth

psi1 = S2DeLaValleePoussinKernel('halfwidth',10*degree)
psi2 = S2DirichletKernel(12)

plot(psi1,'linewidth',2)
hold on
plot(psi2,'linewidth',2)
hold off
xlim([0,60])
legend('de la Vallee Poussin','Dirichlet')

%%
% In contrast to the de la Vallee Poussin kernel the Dirichlet kernel
% oscillates and takes negative values. These oscillations are inherited by
% the estimated density function

pdf2 = calcDensity(cAxes,'kernel',psi2);

plot(pdf2,'upper')
mtexColorbar

%%
% which, in particular, becomes negative in some regions

min(pdf2)

%%
% This is the reason why kernels with non negative values, like the de la
% Vallee Poussin kernel, are the better choice for density estimation.
%
%% Weighted Density Estimation
%
% In many situations the data points should not all contribute equally to
% the density function. The classical example is the computation of a
% texture from grain data, where large grains should have more impact than
% small ones. Such weights are passed by the option |'weights'|.
%
% Lets reconstruct the grains of our EBSD map

[grains,ebsd] = calcGrains(ebsd('indexed'),'angle',10*degree);
grains = grains('Fo');

% one c-axis per grain
cAxesGrains = grains.meanOrientation * grains.CS.cAxis;
cAxesGrains.antipodal = true;

%%
% and compare the unweighted density function of the grain c-axes with the
% one weighted by grain area

mtexFig = newMtexFigure('layout',[1 2]);

plot(calcDensity(cAxesGrains),'upper')
mtexTitle('one grain - one vote')

nextAxis
plot(calcDensity(cAxesGrains,'weights',grains.area),'upper')
mtexTitle('weighted by grain area')

setColorRange('equal')
mtexColorbar
mtexFig.drawNow

%%
% Giving every grain the same vote, the result is dominated by the large
% number of tiny grains and is much flatter than the pixel based density
% function we computed at the beginning of this page. Weighting by grain
% area gives a result that is very close to it - which is not surprising,
% as the number of pixels of a grain is essentially its area.
%
%% Antipodal Symmetry
%
% Whether the input data are interpreted as directions or as axes has a
% direct impact on the resulting density function. Without antipodal
% symmetry we obtain an arbitrary spherical function

v = vector3d.rand(1000);
plot(calcDensity(v),'complete')

%%
% Assuming antipodal symmetry, either by setting the flag on the data or by
% passing the option |'antipodal'| to |calcDensity|, the resulting density
% function is antipodally symmetric as well, i.e., the upper and the lower
% hemisphere carry the same information

plot(calcDensity(v,'antipodal'),'complete')

%%
% A more detailed discussion can be found in the section
% <VectorsAxes.html Axes and Antipodal Symmetry>.
%
%% Working with the Density Function
%
% Once the density function is computed we may analyze it with all the
% tools available for spherical functions, cf. <S2FunOperations.html
% Operations on Spherical Functions>. The most obvious question is where
% the c-axes are concentrated, i.e., where the density function attains its
% maximum

[density,pos] = max(pdf)

%%
% We may also ask for a certain number of local maxima

[density,pos] = max(pdf,'numLocal',3)

%%
% Next we may ask which portion of the c-axes is located within a
% $20^{\circ}$ ball around the strongest maximum. This is exactly what the
% command <S2Fun.volume.html |volume|> computes

volume(pdf,pos(1),20*degree)

%%
% Counting the c-axes directly gives a slightly larger value

mean(angle(cAxes,pos(1)) < 20*degree)

%%
% The difference is a consequence of the smoothing - the kernel spreads a
% sharp maximum out and thereby moves some density out of the ball.
% Reducing the halfwidth reduces the difference.
%
% We may also evaluate the density function at arbitrary directions

pdf.eval([xvector,yvector,zvector])

%%
% If one is interested in the function values only, and not in the density
% function itself, the evaluation points may be passed directly to
% |calcDensity|
%
%   f = calcDensity(cAxes,[xvector,yvector,zvector])
%
% Finally, we may draw a random sample from the estimated density function,
% e.g. in order to reduce a huge data set to a manageable number of
% representative directions

vRand = discreteSample(pdf,500)

plot(pdf,'upper')
hold on
plot(vRand,'MarkerFaceColor','k','MarkerSize',4)
hold off

%% Density Estimation for Crystal Directions
%
% If the input data are of type <Miller.Miller.html |@Miller|>, i.e., if
% they are directions with respect to a crystal reference frame, the
% command <Miller.calcDensity.html |calcDensity|> automatically symmetrizes
% the resulting density function according to the crystal symmetry. A
% typical application is the computation of an inverse pole figure, i.e.,
% the distribution of a specimen direction with respect to the crystal
% coordinate system

% the specimen direction z in crystal coordinates
h = inv(ebsd('Fo').orientations) .* vector3d.Z

%%
% Since |h| is of type |@Miller| the density function inherits the crystal
% symmetry and is of type <S2FunHarmonicSym.S2FunHarmonicSym.html
% |@S2FunHarmonicSym|>

ipdf = calcDensity(h)

%%
% Accordingly, it is sufficient to plot it within the fundamental sector of
% the crystal symmetry

plot(ipdf,'contourf')
mtexColorbar

%%
% The symmetrization may be switched off by the option |'noSymmetry'|.
%
%% Density Estimation on the Fly
%
% Whenever a large set of directions is plotted with one of the smooth
% plotting options, e.g. |'contourf'|, |'smooth'| or |'pcolor'|, MTEX
% silently performs a kernel density estimation with a halfwidth of
% $5^{\circ}$ and displays the result. Hence,

plot(cAxes,'contourf','upper')
mtexColorMap LaboTeX
mtexColorbar

%%
% is a shortcut for computing the density function first and plotting it
% afterwards. As soon as one wants to control the halfwidth, use weights,
% or do any computation with the density function, the explicit call to
% <vector3d.calcDensity.html |calcDensity|> is the way to go.
