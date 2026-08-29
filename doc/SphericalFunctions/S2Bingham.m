%% The Spherical Bingham Distribution
% The Bingham distribution is a compact model for axes on the sphere. An
% axis has no preferred sign, so its density is *antipodally symmetric*:
% the directions $\mathbf{v}$ and $-\mathbf{v}$ always have the same value.
% This makes the model useful when measurements describe lines or planes
% rather than signed vectors.
%
% The preceding <S2FunHarmonicRepresentation.html Harmonic Representation>
% page used many coefficients to describe a general shape. A Bingham
% distribution instead uses three perpendicular principal axes and three
% concentration parameters.

plottingConvention.default('y↑→x');
close all

%% Construct one Bingham distribution
% MTEX stores the concentration parameters as |Z = [z1,z2,z3]|. Adding the
% same constant to all three parameters does not change the normalized
% density, so the largest is conventionally set to zero. The other two are
% nonpositive.
%
% The @vector3d array |a| contains three perpendicular principal axes. A
% random rotation below turns the coordinate axes together while preserving
% their orthogonality.

Z = [-10 -4 0];
a = rotation.rand(1) .* vector3d([xvector yvector zvector]);
bingFun = S2FunBingham(Z,a);

plot(bingFun)
mtexColorbar

%%
% The density has equal maxima at the two ends of |a(3)| because its third
% concentration parameter is zero. The value decreases more rapidly toward
% |a(1)| than toward |a(2)| because -10 is more negative than -4. The
% contours around each maximum are therefore elongated rather than circular.

quadratureMean = mean(bingFun)

%%
% MTEX scales a Bingham density toward a mean value of one over the sphere.
% Its normalization constant uses a saddle-point approximation. The
% independent quadrature check above gives 1.0377 rather than exactly one
% for these parameters, so the remaining 3.8 percent is normalization error.
% Sampling and the locations of the contours are unchanged by this constant.

%% How the concentration parameters change the shape
% The next grid uses |Z = [-k1,-k2,0]| with nonnegative magnitudes
% $k_1\geq k_2$. The five values 0, 4, 8, 12, and 24 show the transition
% from a uniform density to point maxima and girdles.
%
% Equal values $k_1=k_2>0$ give rotationally symmetric point maxima around
% the third axis. Setting $k_2=0$ leaves a *girdle*: a band around the great
% circle perpendicular to the first axis.

kappa = [0 4 8 12 24];
mtexFig = newMtexFigure('layout',[length(kappa) length(kappa)]);
for k2 = kappa
  for k1 = kappa
    if k1 >= k2
      bFun = S2FunBingham([-k1 -k2 0]);
      plot(bFun,'colorRange',[0,25],'noLabel')
      mtexTitle(['$\kappa_1=$' num2str(k1) '  ' ...
        '$\kappa_2=$' num2str(k2)],'FontSize',12)
      nextAxis
    else
      nextAxis
    end
  end
end
setColorRange('equal')
mtexFig.drawNow;

%%
% Read the grid from the uniform case at $k_1=k_2=0$. Along the diagonal,
% both concentrations grow together and the two point maxima narrow.
% Along the $k_2=0$ row, increasing $k_1$ sharpens the girdle. Intermediate
% pairs produce elliptical contours between those two limiting shapes.
% Blank cells omit the redundant cases with $k_1<k_2$.

%% Draw a random sample
% <S2Fun.discreteSample.html |discreteSample|> draws directions with
% probability proportional to the density. The fixed seed above makes the
% sample of 50 directions reproducible.

v = bingFun.discreteSample(50);
sampleSize = length(v)

close all
plot(bingFun)
hold on
plot(v,'MarkerEdgeColor','k','MarkerFaceColor','gray', ...
  'MarkerFaceAlpha',0.5)
hold off

%%
% The directions cluster around both antipodal maxima and spread farther
% along the broad axis of the contours. The sample represents undirected
% axes even though each plotted point uses one signed direction.

%% Fit a Bingham distribution to directions
% Given arbitrarily scattered directions, <S2FunBingham.fit.html |fit|>
% estimates the principal axes and concentrations of the best-fitting
% Bingham distribution. Its second and third outputs describe uncertainty
% in the fitted modal axis.

[bingFunEst,ab,rot] = S2FunBingham.fit(v);
estimatedZ = bingFunEst.Z
semiAxesDegrees = ab ./ degree

plot(bingFunEst)
hold on
plot(v,'MarkerEdgeColor','k','MarkerFaceColor','gray', ...
  'MarkerFaceAlpha',0.5)

% Mark one representative of the fitted modal axis.
annotate(bingFunEst.a(3),'MarkerFaceColor','red','MarkerSize',10)

% Add the default p = 0.95 confidence ellipse.
ellipse(rot,ab(1),ab(2),'linewidth',3,'lineColor','k')
hold off

%%
% The fitted contours follow the same elongated cloud as the observations.
% The red marker selects |bingFunEst.a(3)| as one representative of the
% antipodal modal axis. The black ellipse is the default 95 percent
% confidence region for that fitted axis, not the spread of the density.
% From this sample, the fit estimates |Z| as [-11.95,-3.80,0], close to the
% generating values [-10,-4,0]. Its ellipse semi-axes are 5.48 and 9.58
% degrees.
%
% The method documentation calls this the confidence ellipse of the mean
% direction. For an antipodally symmetric distribution the vector mean
% vanishes, so *modal axis* is the more precise description. The values
% |ab(1)| and |ab(2)| are ellipse semi-axis lengths in radians. The
% orientation |rot| places that ellipse in the tangent plane.

%% The maths behind the Bingham density
% Let $A$ be the orthogonal matrix whose columns are the principal axes and
% let $Z=\mathrm{diag}(z_1,z_2,z_3)$. The probability density with
% respect to spherical surface area is
%
% $$ p_B(\mathbf{x}\mid A,Z) =
% \frac{1}{F(Z)}\exp\!\left(\mathbf{x}^{T}AZA^{T}\mathbf{x}\right). $$
%
% The factor $F(Z)$ is the exact surface-area normalization. MTEX multiplies
% this probability density by $4\pi$ to use its usual mean-one density
% convention, and approximates $F(Z)$ numerically. Because
% $\mathbf{x}^{T}\mathbf{x}=1$, adding a constant to every $z_j$ multiplies
% the numerator by one constant that normalization removes. MTEX therefore
% uses $z_1\leq z_2\leq z_3=0$ for the examples on this page.
%
% The matrix $A$ has previously been called an orthogonal covariance matrix.
% More precisely, it is the orthogonal matrix of principal axes. The
% symmetric matrix $AZA^T$ is the concentration matrix in specimen
% coordinates.

%% References
% * C. Bingham,
% <https://doi.org/10.1214/aos/1176342874 An antipodally symmetric
% distribution on the sphere>, _The Annals of Statistics_ 2 (1974),
% 1201--1225, defines the distribution and derives estimators for its
% concentration and principal-axis parameters.
% * T. Tanaka,
% <https://doi.org/10.1186/BF03351601 Circular asymmetry of the
% paleomagnetic directions observed at low latitude volcanic sites>,
% _Earth, Planets and Space_ 51 (1999), 1279--1286, applies Bingham
% statistics and supplies the uncertainty construction used by |fit|.

%% Next
% Continue with <S2FunRadon.html The Spherical Radon Transform> to integrate
% a spherical function over the great circles perpendicular to selected
% directions.
