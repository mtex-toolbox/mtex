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
% As an example we use the sum of three bumps around the coordinate axes,
% the test function of Gräf, Potts and Steidl.

q = [xvector,yvector,zvector];
sF = S2FunHarmonic(S2FunHandle(@(x) real( exp(-5*acos(dot(x,q(1))).^2) ...
  + exp(-5*acos(dot(x,q(2))).^2) + exp(-5*acos(dot(x,q(3))).^2) )),'bandwidth',48);

plot(sF,'upper','colorbar')

%%
% Note that this function is *not* normalized - it integrates to

sum(sF)

%%
% Any nonnegative function will do. Scaling a density does not move the
% sampling points and does not change their weights, only the mass
% $\lambda = \int_{S^2} f$ that the sample carries.
%
%% Random Sampling
%
% <S2Fun.discreteSample.html |discreteSample|> draws the directions at
% random, with a probability proportional to the function value. This is
% fast and unbiased, but a random sample clusters and leaves holes - the
% picture below shows a lot of both.

rng(0)
vRnd = discreteSample(sF,200);

contourf(sF,'upper')
hold on
scatter(vRnd,'upper','MarkerSize',4,'MarkerFaceColor','k','MarkerEdgeColor','k')
hold off

%% Optimal Sampling
%
% <S2Fun.optimalSample.html |optimalSample|> instead *moves* the directions
% until the discrete measure they form is as close to the density as the
% number of points allows. The result is an almost perfectly equidistributed
% sample - dense where the function is large, sparse where it is small, but
% without the clusters and holes of the random one.

vOpt = optimalSample(sF,200,'bandwidth',32);

contourf(sF,'upper')
hold on
scatter(vOpt,'upper','MarkerSize',4,'MarkerFaceColor','k','MarkerEdgeColor','k')
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
% In the plot the marker size follows the weight. The points still spread
% out evenly, but those in the flanks of the bumps now carry less mass than
% those in the center.

contourf(sF,'upper')
hold on
scatter(vWgt,'upper','MarkerSize',40*c/mean(c),'MarkerFaceColor','k','MarkerEdgeColor','k')
hold off

%%
% Directions that ended up with almost no mass may be dropped right away by
% |minWeight|

[vSmall,cSmall] = optimalSample(sF,200,'bandwidth',32,'minWeight',0.5/200);
length(vSmall)

%% Which Sample Recovers the Density Best?
%
% To answer that we go the way back: estimate a density from the sample with
% <vector3d.calcDensity.html |calcDensity|> - passing the weights along where
% we have them - and measure how far the estimate is from the function we
% started with. The same kernel halfwidth is used for all three samples, so
% what the comparison sees is the quality of the sample alone.

hw = 10*degree;

sFn = sF ./ mean(sF);
err = @(v,w) norm(calcDensity(v,'weights',w,'halfwidth',hw) - sFn);

M = [20 40 80 160 320];
errRnd = zeros(size(M)); errOpt = errRnd; errWgt = errRnd;

for k = 1:length(M)

  % the random sample is averaged over a few draws
  e = zeros(3,1);
  for r = 1:3
    e(r) = err(discreteSample(sF,M(k)),ones(M(k),1));
  end
  errRnd(k) = mean(e);

  v = optimalSample(sF,M(k),'bandwidth',32);
  errOpt(k) = err(v,ones(length(v),1));

  [v,w] = optimalSample(sF,M(k),'bandwidth',32);
  errWgt(k) = err(v,w);

end

close all
loglog(M,errRnd,'-o',M,errOpt,'-s',M,errWgt,'-d','LineWidth',2,'MarkerSize',8)
legend('discreteSample','optimalSample','optimalSample, weighted')
xlabel('number of sampling points')
ylabel('L^2 error of the recovered density')

%%
% The optimized samples are ahead by a wide margin: 20 optimized points
% describe the density as well as 160 random ones, and the weights buy
% another 10 percent on top of that. The curves flatten out because the
% kernel of the density estimation smooths away what a better sample could
% still contribute - beyond about 80 points it is the halfwidth, not the
% sample, that limits the accuracy, and there the weights stop paying too.
%
%% What the Weights Really Buy
%
% The weights pay off where the sample is used as a discrete measure rather
% than as the input of a smoothing kernel, i.e. for integrating against it,
% for its moments, or for the spherical harmonic coefficients up to the
% |bandwidth| the sample was optimized for. That is exactly the quantity
% |optimalSample| minimizes, and it is a much sharper test than the smoothed
% density above.

sF32 = S2FunHarmonic(sF,'bandwidth',32);
mom = @(v,w) norm(sum(sF)*S2FunHarmonic.adjointNFSFT(v(:),w(:)./sum(w), ...
  'bandwidth',32) - sF32) ./ norm(sF32);

momRnd = zeros(size(M)); momOpt = momRnd; momWgt = momRnd;

for k = 1:length(M)

  e = zeros(3,1);
  for r = 1:3
    e(r) = mom(discreteSample(sF,M(k)),ones(M(k),1));
  end
  momRnd(k) = mean(e);

  v = optimalSample(sF,M(k),'bandwidth',32);
  momOpt(k) = mom(v,ones(length(v),1));

  [v,w] = optimalSample(sF,M(k),'bandwidth',32);
  momWgt(k) = mom(v,w);

end

close all
loglog(M,momRnd,'-o',M,momOpt,'-s',M,momWgt,'-d','LineWidth',2,'MarkerSize',8)
legend('discreteSample','optimalSample','optimalSample, weighted')
xlabel('number of sampling points')
ylabel('error of the harmonic coefficients up to degree 32')

%%
% Here the weights make a real difference, and the more points there are the
% larger it gets - with 320 points the weighted sample reproduces the
% harmonic coefficients about three times as accurately as the unweighted
% one, while the random sample is another order of magnitude behind. With
% very few points the two optimized samples coincide: there the directions
% alone already use up everything the sample can express.
%
% So as a rule of thumb: use <S2Fun.discreteSample.html |discreteSample|> when
% you need many points quickly and their individual placement does not matter,
% |optimalSample| when the number of points is limited, and ask for the
% weights whenever the sample is used for integration rather than for a
% kernel density estimate.
%
