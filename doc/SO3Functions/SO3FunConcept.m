%% Rotational Functions
%
%%
% By a rotational function we understand a function that assigns to each
% rotation or orientation a numerical value. An import example of a
% rotational function is the <ODFTheory.html orientation density function
% (ODF)> that assignes to each crystal orientation the probability of its
% occurence within a specimen. Other examples are the Schmidt or the Taylor
% factor as a function of the crystal orientation.
%
%% 
%
% Within MTEX a rotational function is represented by a variable of type
% <SO3Fun.SO3Fun.html |SO3Fun|>. For the moment we consider the following
% ODF

% a predefined ODF
odf = SantaFe

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

[~,pos] = max(odf)

annotate(pos)

%%
% A complete list of operations that can be performed with rotational
% functions can be found in section <SO3FunOperations.html Operations>.

%% Representation of Rotational Functions
%
% Internally MTEX represents rotational functions in different ways:
%
% || by a harmonic series expansion || <SO3FunHarmonicRepresentation.html SO3FunHarmonic> ||
% || as superposition of radial function || @SO3FunRBF ||
% || as superposition of fibre elements || <FibreODFs.html SO3FunCBF> ||
% || as Bingham distribution || <BinghamODFs.html SO3FunBingham> ||
% || as sum of different components || @SO3FunComposition ||
% || explicitely given by a formula || @SO3FunHandle ||
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
