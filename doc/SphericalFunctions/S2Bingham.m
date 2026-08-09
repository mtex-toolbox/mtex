%% The Spherical Bingham Distribution
%%
plottingConvention.default('y↑→x');
%%
% The Bingham distribution on the sphere is an antipodal symmetric
% distribution (Bingham, 1974) with a probability density function given by
%
% $$p_{b}(\hat{x}\vert AKA^T) = \frac{1}{F(\kappa_{1},\kappa_{2},\kappa_{3})}\exp (\hat{x}^T AZA^T \hat{x})$$
%
% where $A$ is an orthogonal covariance matrix, and $Z$ a concentration matrix
% with $\mathrm{diag}(\kappa_{1},\kappa_{2},\kappa_{3})$ with
% $\kappa_{1} < \kappa_{2} < \kappa_{3}$.
%
% In MTEX $Z$ is given by |Z = [k1,k2,k3]| with |k3 = 0| and $A$ is given
% by three orthogonal vectors.
%
% <https://www.jstor.org/stable/2958339 Bingham, C., An Antipodally
% Symmetric Distribution on the Sphere, The Annals of Statistics Vol. 2,
% No. 6 (Nov., 1974), pp. 1201-1225>

% A simple example:
Z = [-10 -4 0];
a = rotation.rand(1) .* vector3d([xvector yvector zvector]);
bingFun = S2FunBingham(Z,a);
plot(bingFun)

%% Meaning of $Z$
% $k1 = k2$ defines a rotational symmetric point maximum and $k2 = 0$
% defines a girdle distribution.
close
kappa = [0 4 8 12 24];
mtexFig = newMtexFigure('layout',[length(kappa) length(kappa)]);
for k2 = kappa
  for k1 = kappa
    if k1 >= k2
      bFun = S2FunBingham([-k1 -k2 0]);
      plot(bFun,'colorRange',[0,25],'noLabel')
       mtexTitle(['$\kappa_1=$' num2str(k1)  '  ' '$\kappa_2=$' num2str(k2)],'FontSize',12)
      nextAxis
    else
      nextAxis
    end
  end
end
setColorRange('equal')
mtexFig.drawNow;

%% Drawing a random sample of the Bingham distribution

close
v = bingFun.discreteSample(50)
plot(bingFun) 
hold on
plot(v,'MarkerEdgeColor','k','MarkerFaceColor','gray','MarkerFaceAlpha',0.5)
hold off


%% Estimating a spherical Bingham distribution from discrete data
%
% Given arbitrarily scattered data |v| on the sphere we can estimate the
% best fitting Bingham distribution by

% estimate a Bingham distribution
[bingFunEst,ab,rot] = S2FunBingham.fit(v)

%%
% Lets plot the fitted distribution with the data

plot(bingFunEst)
hold on
plot(v,'MarkerEdgeColor','k','MarkerFaceColor','gray','MarkerFaceAlpha',0.5)
hold off

%%
% The function <|S2FunBingham.fit, S2FunBingham.fit.html> provides two
% additional output arguments |ab| and |rot|. Those describe the half axes
% $a$ and $b$ and the orientation |rot| of the confidence ellipse of the
% mean mean direction |bingFunEst.a(3)| of the estimated Bingham
% distribution at the confidence level $p=0.95$. We may visualize this
% confidence ellipse by the commands

% mark the mean direction
annotate(bingFunEst.a(3),'MarkerFaceColor','red','MarkerSize',10)

% annotate the p=0.95 confidence ellipse
ellipse(rot,ab(1),ab(2), 'linewidth',3,'lineColor','k')
