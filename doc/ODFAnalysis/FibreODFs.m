%% Fiber ODFs
%
% A fibre ODF is an ODF that is constant along a
% <RotationFibre.html fibre> in orientation space and decays away from it.
% It is the natural model whenever one crystal direction is fixed in the
% specimen while the crystal is free to rotate about it - the classical
% example being wire drawing, where a $\left<111\right>$ direction aligns
% with the drawing axis.
%
%% Defining a fibre ODF
%
% A fibre is represented in MTEX by a variable of type @fibre. Many of the
% named fibres of rolling textures are built in.

cs = crystalSymmetry('cubic')

%%
% define the fibre to be the beta fibre

f = fibre.beta(cs)

%%
% The fibre ODF is then created by <fibreODF.html |fibreODF|>, with a
% halfwidth that controls how quickly the density decays away from the
% fibre.

odf = fibreODF(f,'halfwidth',10*degree)

%%
% plot the odf in 3d

plot3d(odf)

%% Plotting a fibre ODF
%
% Along the fibre itself the ODF is constant, which is easiest to see in a
% <SigmaSections.html sigma section> plot - the fibre shows up as a curve
% of constant intensity

plotSection(odf,'sigma')
mtexColorbar

%%
% and in the pole figures of the directions defining the fibre it collapses
% to a point, while all other pole figures show a ring

plotPDF(odf,Miller({1,0,0},{1,1,0},{1,1,1},cs),'contourf')
mtexColorbar

%% The effect of the halfwidth
%
% The halfwidth is the only shape parameter. Sharper fibres are stronger,
% which is directly visible in the texture index

for hw = [5 10 20]*degree
  odfHw = fibreODF(f,'halfwidth',hw);
  fprintf('halfwidth %4.1f degree : texture index %6.2f, maximum %6.2f\n',...
    hw./degree, norm(odfHw)^2, max(odfHw));
end

%% Fitting a fibre to data
%
% The inverse problem - given an ODF or a set of orientations, which fibre
% describes it best - is solved by <fibre.fit.html |fibre.fit|>

rng(0)
ori = discreteSample(odf,1000);

fFit = fibre.fit(ori)

%%
% Two warnings are in order here. The first is that the fit always returns
% a fibre, whether the data follow one or not - on a unimodal ODF it will
% happily report the fibre through the mode. Section
% <Grain_dispersion_axes.html dispersion axes> shows how the eigenvalues
% returned by |fibre.fit| can be used to judge how fibre like the data
% really are.
%
% The second is that for highly symmetric groups the global search behind
% |fibre.fit| is not reliable. Comparing the mean angular distance of the
% sample to the true and to the fitted fibre shows that on this cubic
% example the fit is clearly worse than the fibre we started from

[mean(angle(ori,f)), mean(angle(ori,fFit))] ./ degree

%%
% For low symmetry, or when a good starting guess is available, the result
% is much better. Treat a cubic fibre fit as a starting point for a manual
% inspection rather than as an answer.

%#ok<*NOPTS>
