%% Rotational Functions
%
%%
% By a variable of type @SO3Fun it is possible to represent an entire
% function on the rotation group $SO(3)$. A typical example of such a
% function is the orientation distribution function (<ODFTheory.html ODF>)

% the famouse Santa Fe orientation distribution function
odf = SantaFe;

%%
% Since, the variable |odf| stores all information about this function we
% may evaluate it for any rotation |r|

% take a random rotation
r = rotation.rand;

% and evaluate the odf at this rotation
odf.eval(r)

%%
% We may also plot the function

plot(odf)

%%
% or find its local maxima

[~,localMax] = max(odf,'numLocal',12)

annotate(localMax)

%%
% A complete list of operations that can be performed with $SO(3)$
% functions can be found in section <SO3FunOperations.html Operations>.
%


%% Representation of Rotational Functions
%
% In MTEX there exist different ways for representing $SO(3)$ functions
% internally. 
%
% || harmonic expansion || @SO3FunHarmonic ||
% || radial basis function || @SO3FunRBF ||
% || fibre elements || @SO3FunCBF ||
% || function handle || @SO3FunHandle ||
% || Bingham distribution || @SO3FunBingham ||
% || sum of the other representations || @SO3FunComposition ||
%
% All representations allow the same operations which are specified for
% the abstact class |@SO3Fun|. In particular it is possible
% to calculate with $SO(3)$ functions as with ordinary numbers, i.e., you
% can add, multiply arbitrary functions, take the mean, integrate them or
% compute gradients, see <SO3FunOperations.html Operations>.
%
%% Generalizations of Rotational Functions
%
% || rotational vector fields || @SO3VectorField ||
% || radial rotational functions || @SO3Kernel ||
%
