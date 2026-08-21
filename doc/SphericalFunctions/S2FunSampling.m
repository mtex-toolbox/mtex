%% Sampling a Spherical Function
%
%%
plottingConvention.default('y↑→x');

%%
% Many computations do not use a density function itself but a finite set of
% directions that represents it - orientations to feed a simulation, a
% discrete measure to integrate against, or simply a scatter plot. This page
% compares the three ways MTEX offers to produce such a sample and shows how
% well each of them recovers the density it came from.
%
% As an example we take the smiley, a function that is zero on most of the
% sphere and concentrated on a few narrow features - which makes it easy to
% see where a sample puts its points.

sF = abs(S2Fun.smiley);

contourf(sF)

%%
% Note that this function is *not* normalized, it integrates to

sum(sF)

%%
% Any nonnegative function will do. Scaling a density moves neither the
% sampling points nor their weights, it only changes the mass
% $\lambda = \int_{S^2} f$ that the sample carries.
%
%% Random Sampling
%
% <S2Fun.discreteSample.html |discreteSample|> draws the directions at
% random, with a probability proportional to the function value. This is fast
% and unbiased, but a random sample clusters and leaves holes - both are easy
% to spot along the mouth below.

rng(0)
vRnd = discreteSample(sF,200);

contourf(sF)
hold on
scatter(vRnd,'MarkerSize',4,'MarkerFaceColor','k','MarkerEdgeColor','k')
hold off

%% Optimal Sampling
%
% <S2Fun.optimalSample.html |optimalSample|> instead *moves* the directions
% until the discrete measure they form is as close to the density as the
% number of points allows. The points end up evenly spread along every
% feature, dense where the function is large and absent where it is zero.

vOpt = optimalSample(sF,200,'bandwidth',32);

contourf(sF)
hold on
scatter(vOpt,'MarkerSize',4,'MarkerFaceColor','k','MarkerEdgeColor','k')
hold off

%%
% The |bandwidth| decides up to which harmonic degree the sample has to
% reproduce the function. Choose it to match the intended use of the points -
% a low bandwidth is cheaper and asks for less.
%
%% Sampling with Weights
%
% The points do not have to carry the same mass. Asking |optimalSample| for a
% second output optimizes the weights alongside the directions, which gives
% the sample $M$ additional degrees of freedom.

[vWgt,c] = optimalSample(sF,200,'bandwidth',32);

%%
% The weights are volume fractions - they are nonnegative and sum up to one

[min(c),max(c),sum(c)]

%%
% Below the marker size follows the weight. The points still spread out
% evenly, but they no longer carry the same share of the density.

contourf(sF)
hold on
scatter(vWgt,'MarkerSize',40*c/mean(c),'MarkerFaceColor','k','MarkerEdgeColor','k')
hold off

%%
% Directions that ended up with almost no mass may be dropped right away with
% |minWeight|

[vSmall,cSmall] = optimalSample(sF,200,'bandwidth',32,'minWeight',0.5/200);
length(vSmall)

%% Which Sample Recovers the Density Best?
%
% To answer that we go the way back: estimate a density from the sample with
% <vector3d.calcDensity.html |calcDensity|> - passing the weights along where
% we have them - and measure how far the estimate is from the function we
% started with. All three samples are given the same kernel halfwidth, so
% what the comparison sees is the quality of the sample alone.
%
% The second measure is the one |optimalSample| actually minimizes: the
% spherical harmonic coefficients of the discrete measure itself, up to the
% |bandwidth| the sample was optimized for, and without any smoothing kernel
% in between. That is what matters when the sample is used for integration
% rather than for a density plot.

hw = 5*degree;
sFn = sF ./ mean(sF);
sF32 = S2FunHarmonic(sF,'bandwidth',32);

dens = @(v,w) norm(calcDensity(v,'weights',w,'halfwidth',hw) - sFn);
mom = @(v,w) norm(sum(sF) * S2FunHarmonic.adjointNFSFT(v(:),w(:)./sum(w), ...
  'bandwidth',32) - sF32) ./ norm(sF32);

M = [50 100 200 400 800];
densRnd = zeros(size(M)); densOpt = densRnd; densWgt = densRnd;
momRnd = densRnd; momOpt = densRnd; momWgt = densRnd;

for k = 1:length(M)

  % the random sample is averaged over a few draws
  d = zeros(3,1); e = zeros(3,1);
  for r = 1:3
    v = discreteSample(sF,M(k));
    d(r) = dens(v,ones(M(k),1));
    e(r) = mom(v,ones(M(k),1));
  end
  densRnd(k) = mean(d); momRnd(k) = mean(e);

  v = optimalSample(sF,M(k),'bandwidth',32);
  densOpt(k) = dens(v,ones(length(v),1));
  momOpt(k) = mom(v,ones(length(v),1));

  [v,w] = optimalSample(sF,M(k),'bandwidth',32);
  densWgt(k) = dens(v,w);
  momWgt(k) = mom(v,w);

end

close all
loglog(M,densRnd,'-o',M,densOpt,'-s',M,densWgt,'-d','LineWidth',2,'MarkerSize',8)
legend('discreteSample','optimalSample','optimalSample, weighted')
xlabel('number of sampling points')
ylabel('L^2 error of the recovered density')

%%
% The optimized samples are ahead by a wide margin - 100 optimized points
% recover the density better than 800 random ones, and no random sample on
% this plot ever catches up. The weights add another 12 percent as long as
% the sample is the bottleneck. All three curves run into the same floor
% around 1.13, which is not a property of the samples: it is what the 5
% degree kernel of the density estimation cannot resolve of a function this
% sharp. Beyond a few hundred points it is the halfwidth that limits the
% accuracy, and there the weights stop paying as well.

close all
loglog(M,momRnd,'-o',M,momOpt,'-s',M,momWgt,'-d','LineWidth',2,'MarkerSize',8)
legend('discreteSample','optimalSample','optimalSample, weighted')
xlabel('number of sampling points')
ylabel('error of the harmonic coefficients up to degree 32')

%%
% Without the kernel in between there is no floor, and the picture is much
% clearer. The optimized samples converge quickly while the random one
% improves only as fast as $1/\sqrt{M}$, and from 100 points on the weights
% are worth a factor of three to four - with 800 points the weighted sample
% reproduces the coefficients about 150 times as accurately as the random one
% and 4 times as accurately as the unweighted optimal one. Only for very few
% points do the two optimized samples coincide: there the directions alone
% already use up everything the sample can express.
%
% So as a rule of thumb: use <S2Fun.discreteSample.html |discreteSample|> when
% you need many points quickly and their individual placement does not matter,
% |optimalSample| when the number of points is limited, and ask for the
% weights whenever the sample is used for integration rather than as the input
% of a kernel density estimate.
