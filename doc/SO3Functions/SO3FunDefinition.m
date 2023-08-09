%% Definition of an SO3Fun
% 
%%
% In MTEX rotational functions $F\colon\mathcal{SO}(3)\to \mathbb C$ are 
% described by subclasses of the super class |@SO3Fun|. Hence we talk about
% them as |SO3Funs|.
%
%% Overview on the subclasses of SO3Fun
%
% Internally MTEX represents rotational functions in different ways:
%
% || by a harmonic series expansion || <SO3FunHarmonicRepresentation.html SO3FunHarmonic> || as Bingham distribution || <BinghamODFs.html SO3FunBingham> ||
% || as superposition of radial function || <RadialODFs.html SO3FunRBF> || as sum of different components || @SO3FunComposition ||
% || as superposition of fibre elements || <FibreODFs.html SO3FunCBF> || explicitely given by a formula || @SO3FunHandle ||
%
%% Generalizations of Rotational Functions
%
% || rotational vector fields || <SO3FunVectorField.html SO3VectorField> ||
% || radial rotational functions || <SO3Kernels.html SO3Kernel> ||
%
%
%% 
% All representations allow the same operations which are specified for
% the abstact class |@SO3Fun|. In particular it is possible
% to calculate with $\mathcal{SO}(3)$ functions as with ordinary numbers, 
% i.e., you can add, multiply arbitrary functions, take the mean, 
% integrate them or compute gradients, see <SO3FunOperations.html Operations>.
%
%% Definition of SO3Fun's
% Every rotational function has a left and a right symmetry, see
% <SO3FunSymmetricFunctions.html symmetric Functions>.
% If we do not specify symmetries by construction then the symmetry group 
% '1' is used as default, i.e. there are no symmetric rotations.
%
% Moreover |SO3Fun's| have the property |antipodal| which could be used to
% set the function as antipodal.
%
%%
%
% *Definition of anonymous functions on SO(3)*
%
% Functions of class |@SO3FunHandle| are defined by an
% <https://de.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html
% anonymous function>.
% 

f = @(ori) angle(ori)./degree
SO3F1 = SO3FunHandle(f)

cs = crystalSymmetry('cubic');
SO3F2 = SO3FunHandle(f,cs)

%%
% Now we are able to evaluate this |@SO3FunHandle|
%

rot = rotation.rand(2);
SO3F2.eval(rot)

%%
% And following that, it is easy to describe every |@SO3Fun| by an
% |@SO3FunHandle|.
%

SO3FunHandle(@(rot) SO3F1.eval(rot))

%%
%
% *Definition of Harmonic Series on SO(3)*
%
% The class |@SO3FunHarmonic| described rotational functions by there 
% harmonic series. MTEX is very fast by computing with this
% |SO3FunHarmonic's|. Hence sometimes it might be a good idea to expand any
% |@SO3Fun| in its harmonic series. Therefore only the command 
% <SO3FunHarmonic.SO3FunHarmonic SO3FunHarmonic> is needed.
% But note that this approximation may lead to inaccuracies.
%

SO3F3 = SO3FunHarmonic(SO3F2)

%%
% Moreover if MTEX computes with an |@SO3FunHarmonic| and any |@SO3Fun| it
% is also expanded to an |@SO3FunHarmonic|. You can prevent that by 
% transformation to a |@SO3FunHandle| like before.
%
%%
% Generally |SO3FunHarmonic's| are defined by there Fourier coefficient 
% vector.
%

fhat = rand(1e4,1);
SO3F4 = SO3FunHarmonic(fhat,cs)

%%
% The |bandwith| decribes the maximal harmonic degree of the harmonic series
% expansion.
%
% By the property |isReal| we are able to change between real and complex
% valued |SO3FunHarmonic's|.
% Note that creation of an real vealued SO3FunHarmonic changes the Fourier
% coefficient vector. So it is not possible to reconstruct the previous
% function. But computing with real valued functions is much faster.
%

SO3F4.eval(rot)

SO3F4.isReal = 1
SO3F4.eval(rot)


%% 
% For further information on the Fourier coefficients, the bandwidth and
% other properties , see 
% <SO3FunHarmonicRepresentation.html Harmonic Representation of Rotational Functions>.
%
%%
%
% *Definition of Radial Basis Functions*
%
% Radial Basis functions are of class |@SO3FunRBF|. They are defined by
% a kernel function |@SO3Kernel| which is cenetered on |orientations| with
% some weights.
%

ori = orientation.rand(1e3,cs);
w = ones(1e3,1);
psi = SO3DeLaValleePoussinKernel
SO3F5 = SO3FunRBF(ori,psi,w,1.2)


%%
% For further information on them, see <RadialODFs.html SO3FunRBF>.
%
%%
%
% *Definition of fibre elements*
%
% They are described by the class |@SO3FunCBF|.
% We construct them by a fibre on SO(3) together with some halfwidth.
%

f = fibre.beta(cs)
SO3F6 = SO3FunCBF(f,'halfwidth',10*degree)

%%
% For further information, see <FibreODFs.html SO3FunCBF>.

%%
%
% *Definition of Bingham distributions*
%
% Bingham distribution functions are described by the class 
% |@SO3FunBingham|. One can construct them by
%

kappa = [100 90 80 0];
U = eye(4);
SO3F7 = BinghamODF(kappa,U,cs)

%%
% For further information, see <BinghamODFs.html SO3FunBingham>.
%
%%
%
% *Sum of different subclasses of SO3Fun*
%
% By adding some subclasses of |@SO3Fun| we can save the sum by storing the
% single components itself.
%

SO3F2 + SO3FunComposition(SO3F4) + SO3F5 + SO3F6 + SO3F7

%%
% Note that the sum of any |@SO3Fun| with an |@SO3FunHarmonic| yields an
% |@SO3FunHarmonic|. Hence you need to add an |@SO3FunHarmonic| in exactly 
% that way. Otherwise the sum is expanded to an |@SO3FunHarmonic| in every
% summation step.


