%% Unimodal ODF Shapes
%
%%
% A <RadialODFs.html unimodal ODF> is a peak, and the *kernel* is the shape
% of that peak - how it falls off with the angle from the centre. The kernel
% is passed to <unimodalODF.html |unimodalODF|> or to
% <fibreODF.html |fibreODF|>, either by its own parameter or, more
% readably, by its halfwidth.
% The halfwidth is the angular distance from the centre at which the kernel
% has fallen to half its maximum. Equal halfwidths therefore align one
% easily interpreted feature, although the tails may still differ greatly.
%
% The choice matters in two places: it is the smoothing applied when a
% density is estimated from measurements, see
% <DensityEstimation.html Density Estimation>, and it decides how many
% harmonic coefficients an ODF needs.

plottingConvention.default('y↑→x');

psi{1} = SO3AbelPoissonKernel(0.79);
psi{2} = SO3DeLaValleePoussinKernel(13);
psi{3} = SO3BumpKernel(35*degree);
psi{4} = SO3DirichletKernel(3);
psi{5} = SO3vonMisesFisherKernel(7.5);
psi{6} = SO3GaussWeierstrassKernel(0.07);
psi{7} = fibreVonMisesFisherKernel(7.2);
psi{8} = SO3SquareSingularityKernel(0.72);

%% The Kernels Themselves
%
% Plotted as one dimensional sections through orientation space - the value
% against the angle from the centre.

% the kernel on SO(3)
close;
figure('position',[100,100,1000,450])
hold on
for i = 1:numel(psi)
  plot(psi{i},'DisplayName',class(psi{i}));
end
hold off
legend(gca,'show','Location','eastoutside')

%%
% The parameters above were chosen to give roughly comparable widths, from
% $15^\circ$ to $37^\circ$, so what the plot shows is the difference in
% *shape*: the bump kernel is exactly zero beyond its halfwidth, the
% Dirichlet kernel oscillates and goes negative, and the rest fall off
% smoothly at different rates.

psi{3}.halfwidth ./ degree

%%
% A negative kernel is not an academic curiosity - an ODF built from it can
% take negative values, which a density must not do.

min(psi{4}.eval(linspace(0,pi,1000)))

%% What They Look Like in a Pole Figure
%
% The Radon transform of the kernel is the shape a single component leaves
% in a pole figure, so this is the curve a measured pole figure peak is
% compared against.

close; figure('position',[100,100,1000,450])
hold on
for i = 1:numel(psi)
  plot(psi{i}.radon,'symmetric','DisplayName',class(psi{i}),'linewidth',2);
end
hold off

ylim([-5,20])

legend(gca,'show','Location','eastoutside')

%% How Many Coefficients They Need
%
% Every kernel is also a series of harmonic coefficients, and how fast those
% decay decides the bandwidth an ODF built from the kernel requires - and
% with it the cost of every harmonic computation.

close; figure('position',[100,100,500,450])
hold on
for i = 1:numel(psi)
  plotSpektra(psi{i},'bandwidth',32,'linewidth',2,'DisplayName',class(psi{i}));
end
hold off
legend(gca,'show')

%%
% The de la Vallee Poussin kernel is finished after 10 coefficients, the von
% Mises Fisher and Gauss Weierstrass kernels after about 11, while the bump
% kernel - the one with the sharp edge in the first plot - needs 1024. A
% function that is not smooth is expensive in a harmonic basis.

psi{2}.bandwidth

%%

psi{3}.bandwidth

%%
% This is why the de la Vallee Poussin kernel is the MTEX default: it is
% smooth, nonnegative, and cheap in both representations.

%% Next
%
% The ODFs built from these kernels are <RadialODFs.html Radial ODFs> and
% <FibreODFs.html Fibre ODFs>. The kernels themselves, with their formulas,
% are collected in <SO3Kernels.html SO3 Kernels>.

%#ok<*NOPTS>
