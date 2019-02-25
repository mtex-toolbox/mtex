%% BinghamS2: spherical Bingham distribution function
%
% The Bingham distribution on the sphere is an antipodal symmetric
% distribution (Bingham, 1974) with a probabiliy density function given by
%
% $p_{b}(\hat{x}\vert AKA^T) = \frac{1}{F(\kappa_{1},\kappa_{2},\kappa_{3})}exp (\hat{x}^T AZA^T \hat{x})$
%
% where A is an orthognal covariance matrix, and Z a concentration matrix
% with $diag(\kappa_{1},\kappa_{2},\kappa_{3})$ with
% $\kappa_{1} < \kappa_{2} < \kappa_{3}$.
%
% In mtex Z is given by Z = [k1,k2,k3] with k3 =0 and A is given by three
% orthognal vectors.
%
% Bingham, C., An Antipodally Symmetric Distribution on the Sphere, The
% Annals of Statistics Vol. 2, No. 6 (Nov., 1974), pp. 1201-1225
% https://www.jstor.org/stable/2958339

% A simple example:
Z = [-10 -4 0]
a = rotation.rand(1).*vector3d([xvector yvector zvector])
bs2=BinghamS2(Z,a);
plot(bs2)

%% Meaning of Z
% k1 = k2 defines a rotationally symmetric point maximum and k2 = 0 defines
% a girdle distribution.
close
kappa = [0 4 8 12 24];
mtexFig = newMtexFigure('layout',[length(kappa) length(kappa)]);
for k2 = kappa
  for k1 = kappa
    if k1 >= k2
      bs=BinghamS2([-k1 -k2 0]);
      plot(bs,'colorRange',[0,25],'TR',['$\kappa_1$:' num2str(k1)],'BR',['$\kappa_2$: ' num2str(k2)],'doNotDraw')
      nextAxis
    else
      nextAxis
    end
  end
end
CLim(mtexFig,'equal')
mtexFig.drawNow;

%% Sample directions from a BinghamS2

close
v = bs2.discreteSample(500)
plot(bs2)
hold on
plot(v,'MarkerFaceColor','k')
hold off


%% Estimating a BinghamS2 from discrete data
% We can estimate a BinghamS2 from a list of directions, let's use v
% Under the assumption of a having a sufficiently large number of points and
% a sufficienly strong distribution, one can estimate also a confidence
% ellipse for the mean direction (default p = 0.95).
bs = BinghamS2.fit(v,'confElli',0.99)
plot(v)
% annotate the ellipse
ellipse(rotation('matrix',bs.a.xyz'),bs.cEllipse(1),bs.cEllipse(2), ...
    'linewidth',2,'lineColor','r','linestyle','-.')
annotate(bs.a(3))
