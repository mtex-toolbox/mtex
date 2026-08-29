%% Orientation-Dependent Functions
%
% An orientation-dependent function assigns a numerical value to every
% rotation or crystal orientation. The set of rotations is the rotation
% group $SO(3)$, which gives the MTEX class @SO3Fun its name.
%
% An important example is the <ODFTheory.html orientation density function
% (ODF)>. It assigns a density to each crystal orientation in a specimen.
% Other examples include the Schmid factor and the Taylor factor as functions
% of crystal orientation.
%
%% A First Orientation-Dependent Function
%
% MTEX represents a scalar function on $SO(3)$ by an object of type
% <SO3Fun.SO3Fun.html |SO3Fun|>. Its symmetries determine which rotations
% represent the same argument.
%
% Consider the smallest rotational angle between an orientation and the
% identity, including its cubic symmetry equivalents. The
% <orientation.angle.html |angle|> command returns this angle in radians.
% Dividing by |degree| makes the function value a number in degrees.

% define cubic crystal symmetry
cs = crystalSymmetry('432');

% wrap the angle formula in an SO3Fun
SO3F = SO3FunHandle(@(ori) angle(ori) ./ degree,cs)

%% Evaluate the Function
%
% @SO3FunHandle turns an
% <https://www.mathworks.com/help/matlab/matlab_prog/anonymous-functions.html
% anonymous function> into an @SO3Fun. The variable |SO3F| now stores the
% formula together with its symmetry.
%
% Use <SO3FunHandle.eval.html |eval|> to evaluate it at one or many
% orientations. Here the input is fixed so that the result is reproducible.

ori = orientation.byEuler(20*degree,30*degree,10*degree,cs)
angleInDegrees = SO3F.eval(ori)

%%
% The returned scalar is the smallest angle, in degrees, among the
% symmetrically equivalent representatives of |ori|. The next page develops
% this construction and the other ways to define an @SO3Fun.

%% Plot Euler-Angle Sections
%
% A scalar function on $SO(3)$ depends on three coordinates. MTEX can show
% it as a stack of sections at fixed third Euler angle $\varphi_2$.

plotSection(SO3F,'sections',4)
mtexColorbar

%%
% Each panel covers the first two Euler angles at one value of $\varphi_2$.
% The colour changes within and between panels because the smallest
% symmetry-reduced angle depends on all three Euler angles.
%
%% Plot Axis--Angle Sections
%
% The same function is especially simple in axis--angle coordinates. Each
% section fixes the rotational angle and varies the rotational axis.

constantContourWarning = warning('off','MATLAB:contour:ConstantData');
plotSection(SO3F,'axisAngle',(15:15:60)*degree,'upper')
warning(constantContourWarning)
mtexColorbar
mtexColorMap parula

%%
% Every panel has one colour because |SO3F| returns the angle that labels
% that panel. The two section plots show the same function in different
% coordinates; neither changes the underlying data.

%% Analyse an Orientation-Dependent Function
%
% The common @SO3Fun interface provides arithmetic, integration,
% differentiation and searches for extrema. For this angle function, a
% local maximum is an orientation farthest from a cubic symmetry equivalent
% of the identity.
%
% The <SO3Fun.max.html |max|> command below requests up to ten distinct local
% maxima. The |accuracy| option controls the final angular search tolerance.

[value,oriMax] = max(SO3F,'numLocal',10,'accuracy',0.001*degree)

%%
% The calculation finds exactly six symmetrically inequivalent maxima. Their
% function values are about 62.799 degrees, and their positions are the
% vertices of the fundamental region in orientation space.

close all
color = ind2color(repmat(1:length(oriMax),numSym(cs),1));
plot(oriMax.symmetrise,color,'axisAngle','filled','markerSize',20,...
  'restrict2FundamentalRegion')

%%
% The six colours distinguish the six maxima. The markers lie on the outer
% vertices because those points have the greatest possible distance from
% the identity after cubic symmetry has been taken into account.

%% Representations of Orientation-Dependent Functions
%
% MTEX can store a function in several ways. The representation controls
% how the function is constructed and how expensive an operation is, but
% all representations share the @SO3Fun interface.
%
% || representation || MTEX class or documentation ||
% || harmonic series expansion || <SO3FunHarmonicRepresentation.html SO3FunHarmonic> ||
% || superposition of radial functions || <RadialODFs.html SO3FunRBF> ||
% || superposition of fibre elements || <FibreODFs.html SO3FunCBF> ||
% || Bingham distribution || <BinghamODFs.html SO3FunBingham> ||
% || sum of different components || @SO3FunComposition ||
% || formula evaluated on demand || @SO3FunHandle ||
%
% Thus functions with different internal representations can be added,
% multiplied, averaged, integrated or differentiated through the same API.

%% Related Function Types
%
% <SO3FunVectorField.html SO3VectorField> assigns a vector instead of a
% scalar to each rotation. <SO3Kernels.html SO3Kernel> represents a radial
% function whose value depends only on rotational angle.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, 1982, develops
% the orientation-space and ODF framework used here.

%% Next
%
% Continue with <SO3FunDefinition.html Defining Orientation-Dependent
% Functions> to construct functions from formulas, harmonic coefficients
% and sampled values.
