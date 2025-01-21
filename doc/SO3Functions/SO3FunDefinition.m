%% Definition of Orientation Dependent Functions
% 
%% Types of Orientation Dependent Functions
%
% In MTEX any rotation / orientation dependent function is a variable of
% type @SO3Fun. Internally, MTEX supports different types of representing
% such functions, e.g. by harmonic expansion or as superposition of kernel
% functions which are implemented as subclasses of the super class @SO3Fun:
%
% || harmonic series expansion || <SO3FunHarmonicRepresentation.html |SO3FunHarmonic|> || Bingham distribution || <BinghamODFs.html SO3FunBingham> ||
% || superposition of radial functions || <RadialODFs.html SO3FunRBF> || arbitrary superposition || @SO3FunComposition| ||
% || superposition of fibre elements || <FibreODFs.html SO3FunCBF> || explicit formula || @SO3FunHandle ||
%
% All representations allow for nearly the same operations. Furthermore,
% you can freely combine different representations within one expression.
% The most general representation is |SO3FunHarmonic|, i.e. every
% orientation dependent function |S3F| can be transformed into a harmonic
% series expansion using the syntax |SO3FunHarmonic(S3F)|. That
% transformation is known as <Quadrature.html quadrature>. Furthermore,
% many operations are only possible or significantly faster in the harmonic
% representation.
%
% Additionally, MTEX supports orientation dependent vector fields by the
% class <SO3FunVectorField.html SO3VectorField>.
%
% In the following, we quickly show to set up the different types of
% orientation dependent functions.
%
%% By an explicit formula
%
% Assume we have an explicit formula or algorithm to compute for an
% orientation a value. This could be the Taylor factor or any other
% physical property. Here we simply use the rotational angle. In order to
% a variable of type @SO3Fun representing the rotational angle in degree we
% to do two steps.
%
% *Step 1: Define the relationship as an anonymous functions on SO(3)*
% 
% The concept of anonymous functions in Matlab is explained
% <https://de.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html
% here>. In shorts it assigns a command / formula to a variable. 

f = @(ori) angle(ori)./degree

%%
% *Step 2: Define a variable of type |SO3FunHandle|*
%
% Next, we use the anonymous function to define a variable of type
% @SO3FunHandle.

% define a crystal symmetry
cs = crystalSymmetry('cubic');

% define the SO3Fun
SO3F = SO3FunHandle(f,cs)

% visualize the function
plot(SO3F)

%%
% The plot shows the variation of the rotational angle with respect to the
% Euler angles under consideration of the crystal symmetry.

%% As Harmonic Expansion
%
% As mentioned above we can translate any orientation dependent function
% into its harmonic series expansion. This is done by the command
% @SO3FunHarmonic.

% transform SO3F into a harmonic series expansion
SO3F = SO3FunHarmonic(SO3F,'bandwidth',16)

% visualize the function
plot(SO3F)

%%
% The difference to the previous plot is the cut off error due to the fixed
% bandwidth. Choosing a larger bandwidth would reduce the cut off error.
% Currently, a bandwidth of up to 128 works reasonably fast in MTEX. We may
% visualize the decay of the harmonic coefficients as follows

close all
plotSpektra(SO3F,'linewidth',2)

%% 
% For further information on the Fourier coefficients, the bandwidth and
% other properties, see <SO3FunHarmonicRepresentation.html Harmonic
% Representation of Rotational Functions>.
%
%% Superposition of Radial Functions
%
% Radial functions are functions that depend only on the distance to some
% reference orientation. Typical examples are the de la Vallee Poussin
% kernel, the Abel Poisson kernel, the Gauss Weierstrass kernel or the von
% Mises Fisher kernel. The characterizing parameter of all these kernel
% functions is their halfwidth, i.e., the angular distance at which the
% function values is only half the function value at the center. 

% define the kernel de la Vallee Poussin kernel with halfwidth 15 degree
psi = SO3DeLaValleePoussinKernel('halfwidth',15*degree)

close all
plot(psi)


%%
% Using a large number of such kernel functions centered at different
% orientations allows to approximate arbitrary orientation dependent
% function. In MTEX superposition of radial functions naturally occur when
% performing ODF reconstruction from pole figure data or kernel density
% estimation from a small number of orientations, e.g.

% some random orientations
ori = orientation.rand(200,cs);

% perform kernel density estimation
SO3F = calcDensity(ori,'kernel',psi)

%%
% For further information see <RadialODFs.html |superposition of radial
% function|>.
%
%% Superposition of Fiber Elements
%
% Similarly as with radial functions, we may also represent an orientation
% dependent function also as a superposition of fibre components. The
% typical case is that we want to model an fiber ODF. This can be done as
% follows

% define a fibre
f = fibre.beta(cs)

% define a density function along this fiber
SO3F = SO3FunCBF(f,'halfwidth',10*degree)

% plot it
plot(SO3F)

%%
% For further information, see <FibreODFs.html fiber ODFs>.
%
%% The Bingham Distribution
%
% A last family of orientation dependent functions are
% <SO3FunBingham.SO3FunBingham.html Bingham distributions>. Those are
% parameterized by a vector |U| of four orientations and a vector |kappa|
% of four values specifying the length and direction the half axes of a
% four dimensional ellipsoid. 

kappa = [100 90 80 0];
U = [orientation.byAxisAngle(xvector,[0,180]*degree,cs),...
  orientation.byAxisAngle([yvector,zvector],180*degree,cs)]
  
SO3F = BinghamODF(kappa,U)

plot(SO3F)

%%
% For further information, see <BinghamODFs.html SO3FunBingham>.
%
