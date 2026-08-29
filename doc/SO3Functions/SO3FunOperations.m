%% Operations on Orientation-Dependent Functions
%
% The common @SO3Fun interface lets you calculate with functions much as
% MATLAB calculates with arrays. This page starts from two functions and
% uses them for arithmetic, extrema, integration, differentiation and
% rotation. See <SO3FunDefinition.html Defining Orientation-Dependent
% Functions> first if the representations are unfamiliar.
%
%% Two Example Functions
%
% The first function is the Dubna ODF determined from neutron diffraction
% data. An ODF is an orientation density function.

plottingConvention.default('y↑→x');
SO3F1 = SO3Fun.dubna

close all
plot(SO3F1,'sigma','sections',4)
mtexColorbar

%%
% The unequal colours show that the measured orientations are not uniformly
% distributed. Several maxima appear across the sigma sections rather than
% one isolated ideal component.
%
% The second function is a unimodal ODF. It places one radial kernel at the
% orientation |R|.

R = orientation.byAxisAngle(vector3d.Y,pi/4,SO3F1.CS);
SO3F2 = SO3FunRBF(R,SO3DeLaValleePoussinKernel)

close all
plot(SO3F2,'sigma','sections',4)
mtexColorbar

%%
% In contrast to the measured ODF, this plot contains one concentrated
% component. Its appearance in neighbouring sections is the cross-section
% of one three-dimensional peak in orientation space.

%% Arithmetic
%
% Adding functions or scaling them produces another @SO3Fun. MTEX can
% combine different internal representations in the same expression.

combined = 2 * SO3F1 + SO3F2;
shiftedCombined = 1 + combined

close all
plot(combined,'sigma','sections',4)
mtexColorbar

%%
% The combined plot retains features of the measured ODF and adds the
% narrow component from |SO3F2|. The constant in |shiftedCombined| raises
% every value equally, so it does not change the positions of those features.
%
% Basic overloaded operations include |-|, scalar |*|, scalar |/|,
% pointwise |.*|, pointwise |./| and pointwise |.^|.
% Pointwise <SO3Fun.abs.html |abs|>, <SO3Fun.sqrt.html |sqrt|>,
% <SO3Fun.conj.html |conj|>, <SO3Fun.exp.html |exp|> and
% <SO3Fun.log.html |log|> also return functions.

%% Pointwise Minimum and Maximum
%
% With two function arguments, <SO3Fun.max.html |max|> and
% <SO3Fun.min.html |min|> compare values independently at every orientation.

pointwiseMax = max(2*SO3F1,SO3F2);
close all
plot(pointwiseMax,'sigma','sections',4)
mtexColorbar

%%
% At every plotted orientation, the colour comes from whichever input has
% the larger value. The narrow peak survives where it rises above the
% doubled measured ODF.

pointwiseMin = min(2*SO3F1,SO3F2);
close all
plot(pointwiseMin,'sigma','sections',4)
mtexColorbar

%%
% The minimum keeps the lower input instead. It clips each function wherever
% the other lies below it. Passing one function and one scalar performs the
% same comparison against a constant threshold.

%% Inverting the Argument
%
% The <SO3Fun.inv.html |inv|> operation composes a function with inversion.
% If |g = inv(f)|, then the value of |g| at a rotation is the value of |f|
% at the inverse rotation.
%
% Applying |inv| directly to the @SO3FunRBF |SO3F1| does not currently
% reproduce this identity for the Dubna ODF. Converting to a harmonic
% representation gives a reliable check.

SO3F1Harmonic = SO3FunHarmonic(SO3F1,'bandwidth',16);
g = inv(SO3F1Harmonic)

testRot = rotation(R);
valueAtR = SO3F1Harmonic.eval(testRot)
inverseValue = g.eval(inv(testRot))

%%
% The two displayed values agree, which checks the relation
% $g(\mathbf{R}^{-1}) = f(\mathbf{R})$ for this orientation.

%% Global and Local Extrema
%
% The number and type of arguments change what |min| and |max| return.
%
% * With one @SO3Fun, they return its global extremum and its position.
% * With two functions, they return the pointwise minimum or maximum
% function shown above.
% * With one function and one scalar, they return a pointwise clipped
% function.
% * With |'numLocal',n|, they return up to |n| distinct local extrema and
% their positions.
%
% The following search asks for the two largest local maxima of |combined|.

close all
plot(combined,'phi2',(0:3)*30*degree)
mtexColorbar

[maxValue,maxNodes] = max(combined,'numLocal',2)
annotate(maxNodes)

%%
% The annotations mark the two returned orientations. The first value is
% the global maximum, while the second is the next distinct local maximum.

%% Integration and Norms
%
% <SO3Fun.mean.html |mean|> returns the normalized integral over $SO(3)$.
% It assigns the constant function one an integral of one.
% <SO3Fun.sum.html |sum|> uses the full rotation-group volume $8\pi^2$.

normalizedIntegral = mean(SO3F1)
integralFromSum = sum(SO3F1) / (8*pi^2)

%%
% These two values agree because dividing |sum| by $8\pi^2$ gives the same
% normalization as |mean|.
%
% With this normalized measure, the $L^2$ norm of a function is
%
% $$ \lVert f \rVert_2 = \left( \frac{1}{8\pi^2}
% \int_{SO(3)} \lvert f(\mathbf{R}) \rvert^2\,\mathrm d\mathbf{R}
% \right)^{1/2}. $$
%
% It can be assembled from pointwise operations and |mean|.

normFromDefinition = sqrt(mean(abs(SO3F1).^2))

%%
% The dedicated <SO3Fun.norm.html |norm|> command computes the same quantity
% more efficiently. A small difference between the displayed results comes
% from the numerical approximations used by the two routes.

directNorm = norm(SO3F1)

%% Differentiation at One Orientation
%
% The gradient at a particular orientation belongs to the tangent space of
% $SO(3)$ at that orientation. MTEX represents it by an
% <SO3TangentVector.SO3TangentVector.html SO3TangentVector>.

gradientAtR = grad(SO3F1,R)

%%
% Roughly speaking, this tangent vector points in the direction of steepest
% ascent. Following it through the exponential map produces a new rotation.
% See <RotationTangentSpace.html Tangent Space Representation on SO(3)> for
% that construction.

%% The Gradient Field
%
% Without an evaluation orientation, <SO3Fun.grad.html |grad|> returns the
% gradients at all orientations as an @SO3VectorFieldHarmonic.

G = grad(SO3F1)

close all
plot(SO3F1,'sigma','sections',4)
hold on
plot(G,'color','black','linewidth',1,'resolution',5*degree)
hold off

%%
% The section plot lays down a grey arrow field of its own, and the gradient
% is drawn in black on top of it. Read the black arrows. They are long where
% the ODF intensity changes quickly and almost invisible where it is nearly
% constant, and each points along the local direction of steepest ascent
% represented in that section.

%% Rotating a Function
%
% <SO3Fun.rotate.html |rotate|> moves an orientation-dependent function by
% a specified rotation. This changes where its features occur. It is not a
% frame change, which would re-express the same physical function in a
% different reference frame.

rot = rotation.byEuler(30*degree,0*degree,90*degree,'Bunge');
rotated = rotate(SO3FunHarmonic(combined),rot)

close all
plot(rotated,'sigma','sections',4)
mtexColorbar

%%
% Compared with the earlier plot of |combined|, the same pattern is shifted
% through orientation space. Its amplitudes and internal arrangement are
% preserved by the rotation.

%% References
%
% * H.-J. Bunge, <https://doi.org/10.1016/C2013-0-11769-2 Texture Analysis
% in Materials Science: Mathematical Methods>, Butterworths, 1982, gives
% the orientation-space integration and ODF normalization used here.

%% Next
%
% Continue with <ODFPlot.html Plotting Orientation Functions> to choose
% section types, projections and colour ranges for inspecting an @SO3Fun.
