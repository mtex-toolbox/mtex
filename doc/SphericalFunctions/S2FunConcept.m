%% Spherical Functions
%
%%
% A great deal of what texture analysis produces is a function on the
% sphere: a pole density, an inverse pole density, a directional magnitude
% of a tensor, a wave velocity. MTEX represents all of them by one kind of
% object, an |@S2Fun|, which can be evaluated anywhere, plotted, added,
% integrated and searched for maxima - whatever it was computed from.

% the famous Santa Fe orientation distribution function
odf = SantaFe;

% the (100) pole density function
pdf = odf.calcPDF(Miller(1,0,0,odf.CS))

%%
% Note what this is not: a grid of values. It is the function itself, so it
% can be evaluated at any direction, including ones no grid contained.

% take a random direction
r = vector3d.rand;

% and evaluate the pdf at this direction
pdf.eval(r)

%%
% Plotting it is evaluating it on whatever grid the projection needs -
% <SphericalProjections.html the projection> is chosen at plotting time and
% is not a property of the function.

plot(pdf)

%%
% and asking for its extrema is a search over the function rather than over
% a grid, so the answer is not limited by a resolution:

[~,localMax] = max(pdf,'numLocal',12)

annotate(localMax)

%%
% Six come back although twelve were asked for: |'numLocal'| is an upper
% limit, and this function has six distinct local maxima once antipodal
% directions are identified with each other, as they are in a pole figure.
% The full set of operations is in <S2FunOperations.html Operations>.

%% Representations
%
% Behind that one interface there are several representations, differing in
% what they store:
%
% || harmonic expansion || @S2FunHarmonic ||
% || finite elements || @S2FunTri ||
% || function handle || @S2FunHandle ||
% || Bingham distribution || @S2FunBingham ||
%
% The choice matters for speed and for what can be computed exactly - a
% harmonic expansion integrates and convolves cheaply, a function handle
% evaluates exactly and does nothing else quickly - but not for the syntax.
% Anything written against |@S2Fun| works with all of them, and arithmetic
% between two functions works as it does between numbers.

%% Generalisations
%
% The same idea extends to functions whose values are not scalars, and to
% functions with a symmetry built in:
%
% || spherical vector fields || @S2VectorField ||
% || spherical axis fields || @S2AxisField ||
% || radial spherical functions || @S2Kernel ||
% || symmetric spherical functions || @S2FunHarmonicSym ||
%
% An axis field is not a vector field with a sign convention: it is a field
% whose values are axes, so that a value and its negative are the same
% value, which is what a direction without a sense requires.
