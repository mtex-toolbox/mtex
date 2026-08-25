%% Spherical Grids
%
%%
% Numerical work on the sphere needs a set of directions spread over it as
% evenly as possible - to integrate a spherical function, to sample one, or
% to draw it. Unlike a plane, a sphere has no rectangular grid with uniform
% spacing everywhere. Grid constructions therefore make different tradeoffs
% between spacing, equal-area cells and a regular data structure.

plottingConvention.default('y↑→x');

%% Four Constructions
%
% MTEX offers the <regularS2Grid.html |regularS2Grid|>, the
% <equispacedS2Grid.html |equispacedS2Grid|>, the
% <HEALPixS2Grid.html |HEALPixS2Grid|> and the
% <fibonacciS2Grid.fibonacciS2Grid.html |fibonacciS2Grid|>. Each accepts a
% target angular |resolution|, but the constructors interpret that target
% according to their own geometry; it is not a guarantee that every pair of
% neighbours has exactly that separation.

% a regular grid in the two spherical angles
grid{1} = regularS2Grid('resolution',7*degree);

% the MTEX equispaced grid
grid{2} = equispacedS2Grid('resolution',7*degree);

% the HEALPix grid
grid{3} = HEALPixS2Grid('resolution',7*degree);

% the Fibonacci grid
grid{4} = fibonacciS2Grid('resolution',7*degree);

names = {'regular','equispaced','HEALPix','Fibonacci'};

%%
% Seen from above they differ most at the pole.

plot(grid{1},'upper','layout',[1 4])
mtexTitle(names{1})

for k = 2:4
  nextAxis
  plot(grid{k},'upper')
  mtexTitle(names{k})
end

%%
% The number of nodes in the four grids is

cellfun(@length,grid)

%%
% The regular grid takes the same number of azimuth steps on every circle of
% latitude, so its points crowd together towards the pole and it uses 1404
% nodes here, compared with 812, 768 and 827. The other three keep their node
% density roughly constant as circles of latitude get shorter.

%% Comparison of Uniformity
%
% Node uniformity can be diagnosed rather than only eyeballed.
% <VectorsDensityEstimation.html Density estimation> gives every node equal
% weight and smooths the nodes into a function on the sphere. A uniform node
% density would be close to the constant $1$. This tests equal-weight node
% placement; it does not by itself test the accuracy of a particular
% quadrature rule.

for k = 1:4
  d(k) = calcDensity(grid{k},'halfwidth',5*degree);
end

clf
for k = 1:4
  plot(d(k),'upper','layout',[2,2]);
  mtexTitle(names{k})
  if k<4, nextAxis, end
end
mtexColorbar

%%
% The three even grids are almost flat, the regular one carries a hot spot
% at the pole where its points pile up. The deviation from the constant is
% the norm of the difference,

norm(d-1).'

%%
% or, integrating the deviation instead of its square,

sum(abs(d-1)).'

%%
% For this resolution and smoothing width, roughly two orders of magnitude
% separate the regular grid from the other three, and the Fibonacci grid has
% the smallest deviations. That does not make the regular grid useless: its
% points sit on a rectangular mesh in the two spherical angles, which is
% what a contour or surface plot needs, and what
% <regularS2Grid.html |regularS2Grid|> exists for. For integration or
% sampling where nearly uniform, equal-weight nodes are wanted, choose one
% of the other constructions and check whether the downstream method needs
% its own quadrature weights or grid structure.
%
%% Next
%
% Grids on the rotation group rather than on the sphere, and grids that
% respect crystal symmetry, are covered in
% <OrientationGrid.html Orientation Grids>. Choosing points so that a
% spherical function is sampled as informatively as possible is a different
% question, treated in <S2FunSampling.html Sampling>.

%#ok<*NOPTS>
%#ok<*SAGROW>
