%% Vector Fields in Orientation Space
%
% A vector field on the rotation group assigns a tangent vector to every
% orientation. Evaluating an @SO3VectorField at an orientation $R$ returns
% an @SO3TangentVector attached to $R$.
%
% Read <RotationTangentSpace.html The Tangent Space on the Rotation Group>
% first for the definition of tangent vectors and their left and right
% representations. Vector fields model orientation-dependent spin in
% Taylor and Sachs calculations. The gradient of an orientation
% distribution function (ODF) is another important example.

plottingConvention.default('y↑→x');

%% A first vector field: the gradient of an ODF
%
% Consider the model ODF for a quartz specimen known as the Dubna texture.
% The gradient points in the direction of the fastest local increase of
% the ODF, and its norm gives that rate of increase.

odf = SO3Fun.dubna;
G = odf.grad

%%
% Evaluation at one sampled orientation returns the tangent vector attached
% to that orientation.

ori = odf.discreteSample(1);
G.eval(ori)

%%
% Plot the ODF in sigma sections and draw the gradient arrows on top.

plot(odf,'sigma')
hold on
plot(G,'linewidth',1.5,'color','black','resolution',7.5*degree)
hold off

%%
% The arrows point uphill towards the nearest local maximum. Their lengths
% increase where the ODF changes more steeply. This ascent direction is the
% basis of the <SO3Fun.steepestDescent.html steepest-descent algorithm>
% used by <SO3Fun.max.html |max|> and
% <SO3Fun.calcComponents.html |calcComponents|>.

%% Three representations
%
% MTEX provides three interchangeable representations. A harmonic or RBF
% field stores three scalar component functions using the array convention
% introduced in <SO3FunVectorValued.html Vector-Valued Orientation
% Functions>.
%
% || representation || class || when to use it ||
% || three harmonic component functions || <SO3VectorFieldHarmonic.SO3VectorFieldHarmonic.html |SO3VectorFieldHarmonic|> || differentiation and global spectral approximation ||
% || three radial-basis component functions || <SO3VectorFieldRBF.SO3VectorFieldRBF.html |SO3VectorFieldRBF|> || approximation by local kernels ||
% || an evaluation formula || <SO3VectorFieldHandle.SO3VectorFieldHandle.html |SO3VectorFieldHandle|> || an explicit rule that can be evaluated at any orientation ||
%
% All three representations support the common @SO3VectorField operations.

%% Left and right tangent-vector coordinates
%
% An @SO3VectorField has a requested tangent-space representation and two
% associated symmetries. Left coordinates are the default. The
% <SO3VectorField.right.html |right|> and
% <SO3VectorField.left.html |left|> methods re-express the same geometric
% vectors; they do not change the vectors or their base orientations.

GR = right(G)
v = GR.eval(ori);
vRight = right(G.eval(ori));
norm(v-vRight)

%%
% The zero residual shows that converting the field before evaluation and
% converting the evaluated tangent vector give the same result.
% Arithmetic also converts compatible fields to a common representation
% automatically.

G + GR

%% Why the visible symmetries change
%
% A field has an internal tangent-space representation used for storage and
% an external representation requested through its |tangentSpace|
% property. Evaluation first constructs the tangent vector in the internal
% representation and then converts it to the requested representation.
%
% Symmetry acts differently on the two coordinate choices. For a
% right-represented tangent vector, evaluations at symmetry-equivalent
% orientations are meaningful only with respect to the left symmetry. For
% a left-represented tangent vector, the reverse applies.

ori = orientation.rand(G.CS,G.SS);
G.eval(ori.symmetrise)
GR.eval(ori.symmetrise)

%%
% MTEX therefore keeps the original crystal and specimen symmetries in two
% hidden properties. The symmetry of the internal three-component @SO3Fun
% depends on the internal tangent space. The externally visible symmetry
% depends on the requested tangent space. This is why |G| and |GR| have
% different external symmetries even though they describe the same field.

%% Operations on vector fields
%
% The following operations apply to vector fields |VF|, |VF1| and |VF2|:
%
% * sums, differences, scaling and division
% * inner products with <SO3VectorField.dot.html |dot(VF1,VF2)|>
% * cross products with <SO3VectorField.cross.html |cross(VF1,VF2)|>
% * norms with <SO3VectorField.norm.html |norm(VF)|>
% * squared norms with <SO3VectorField.normSquare.html |normSquare(VF)|>
% * normalization with <SO3VectorField.normalize.html |normalize(VF)|>
% * rotation with <SO3VectorField.rotate.html |rotate(VF,rot)|>
% * averages with <SO3VectorField.mean.html |mean(VF)|>
%
% Since a gradient is itself a vector field, MTEX can also compute its
% divergence, curl and scalar antiderivative.

%% Divergence and the Laplacian
%
% Treating |G| as an orientation-space velocity field gives an intuitive
% reading of its divergence. Negative divergence marks a sink where nearby
% orientations condense. Positive divergence marks a source where they
% spread apart.
%
% The divergence of a gradient equals the Laplacian of its scalar field.
% Plot the two calculations side by side at the same sigma section.

plot(G.div,'sigma',60*degree)
nextAxis
plot(laplace(SO3FunHarmonic(odf)),'sigma',60*degree)
mtexColorbar

%%
% The source and sink regions, contour shapes and colour scale agree in the
% two panels. The left panel was computed from the vector field, whereas
% the right panel was computed directly from the ODF.

%% Curl and conservative fields
%
% Curl describes the axis of local circulation within orientation space.
% The curl of a gradient is zero, so the next plot should contain no
% nonzero arrows.

plot(G.curl,'sigma')

%%
% Vanishing curl identifies a conservative field: a field that is the
% gradient of a scalar potential. The
% <SO3VectorField.antiderivative.html |antiderivative|> method reconstructs
% that potential.

odf2 = G.antiderivative

%%
% A gradient loses the additive constant of its source function. Restoring
% the original mean makes the reconstructed potential coincide with |odf|.

odf2 = odf2 + mean(odf);
plot(odf2,'sigma')

%% Define a field by an evaluation formula
%
% An anonymous function is convenient when a vector formula is known. The
% following rule uses the rotation axis multiplied by the rotation angle,
% with cubic symmetry on both sides.

cs = crystalSymmetry('432')
f = @(mori) axis(mori) .* angle(mori);
VF = SO3VectorFieldHandle(f,cs,cs)

%%
% Evaluating a $10^\circ$ rotation about $[1\;2\;3]$ and reducing the axis
% to small integers recovers the expected direction ratio $1:2:3$.

round(VF.eval(orientation.byAxisAngle(vector3d(1,2,3),10*degree)))

%%
% The following axis-angle plot samples the formula throughout the cubic
% fundamental region. Arrow count is consistent with that small region.
% The arrow directions have not been verified independently against
% |eval| for an @SO3VectorFieldHandle, so use the plot qualitatively and
% treat evaluated values as authoritative.

quiver3(VF,'axisAngle','resolution',7.5*degree,'color','black',...
  'linewidth',2)

%% Convert a field to harmonic form
%
% Passing any @SO3VectorField to the harmonic constructor expands its three
% components by quadrature.

SO3VectorFieldHarmonic(VF)

%% Fit harmonic components to sampled values
%
% A second construction starts from rotations and one @vector3d value at
% each rotation. The first array dimension again corresponds to nodes.

nodes = equispacedSO3Grid(specimenSymmetry('1'),'points',1e3);
nodes = nodes(:);
y = vector3d.byPolar(sin(3*nodes.angle),nodes.phi2+pi/2);

%%
% The approximation below produces a harmonic vector field with bandwidth
% 16.

SO3VF1 = SO3VectorFieldHarmonic.approximate(nodes,y,'bandwidth',16)

%% Construct by quadrature of a function handle
%
% A handle that accepts a @rotation and returns a @vector3d can also be
% passed directly to quadrature. Here the earlier cubic formula produces a
% harmonic vector field.

SO3VF2 = SO3VectorFieldHarmonic.quadrature(@(v) f(v))

%% Construct from three scalar harmonic functions
%
% A three-component @SO3FunHarmonic can be wrapped directly. Its first,
% second and third entries become the $x$, $y$ and $z$ components of the
% vector field.

SO3F = SO3FunHarmonic(rand(1e3,3))
SO3VF3 = SO3VectorFieldHarmonic(SO3F)

%% Application: orientation-dependent spin in the Taylor model
%
% Taylor theory accommodates a prescribed strain by activating slip
% systems in each crystal. The antisymmetric part of the resulting
% deformation describes the local lattice spin, and therefore the local
% misorientation predicted for each orientation. Without an input
% orientation, <strainTensor.calcTaylor.html |calcTaylor|> returns this
% spin as an @SO3VectorField.

cs = crystalSymmetry('432');
sS = slipSystem.bcc(cs)

%%
% Set plane strain with $q=0$ and calculate the spin field for the
% symmetrised body-centred-cubic slip systems.

q = 0;
epsilon = strainTensor(diag([1 -q -(1-q)]))
[~,~,W] = calcTaylor(epsilon,sS.symmetrise)

%%
% Display the spin directions in four Euler-angle sections.

sP = phi1Sections(cs,specimenSymmetry('222'));
sP.phi1 = (10:20:70)*degree;
plot(W,sP,'resolution',7.5*degree,'layout',[2 2])

%%
% Direction and length vary with orientation, showing that the Taylor model
% predicts a different local misorientation across orientation space. The
% value at the copper orientation can be retrieved directly.

WCopper = W.eval(orientation.copper(cs))

%% The amount of spin
%
% The norm of the spin vector is the angle of local misorientation. Its
% maximum locates the orientation with the largest predicted rotation.

[~,oriMax] = max(norm(W))

%%
% Plot the norm at $0.5^\circ$ resolution and overlay the more coarsely
% sampled vector field. The background shows magnitude, the arrows show
% direction, and the annotation marks |oriMax|.

plot(norm(W),sP,'resolution',0.5*degree,'layout',[2 2])
mtexColorMap LaboTeX
hold on
plot(W,sP,'resolution',7.5*degree,'color','black')
hold off
annotate(oriMax)

%% Compare spin with a crystal direction
%
% Since |W| gives the rotation axis of the local misorientation, its inner
% product with a chosen direction measures signed alignment. Here the
% direction is crystal $[100]$.

plot(dot(W,Miller(1,0,0,cs)),sP,'layout',[2 2])
mtexColorMap blue2red
mtexColorbar

%%
% Positive and negative regions indicate parallel and antiparallel
% components along $[100]$. Values near zero indicate that the spin axis is
% locally perpendicular to that direction.

%% Sources and sinks of the Taylor spin field
%
% Finally compute the divergence of |W|. As in the gradient example,
% negative values are sinks and positive values are sources in orientation
% space.

flux = W.div
plot(flux,sP,'resolution',0.5*degree,'layout',[2 2],...
  'faceAlpha',0.5)
mtexColorMap blue2red
mtexColorbar

%%
% The alternating red and blue regions show that the Taylor spin field
% moves orientations towards some parts of orientation space and away from
% others.

close all

%% References
%
% * A. Morawiec,
% <https://doi.org/10.1007/978-3-662-09156-2 Orientations and Rotations:
% Computations in Crystallographic Textures>, Springer, 2004, develops the
% tangent-space geometry used for gradients and vector fields on
% $\mathrm{SO}(3)$.
% * H.-J. Bunge,
% <https://doi.org/10.1002/crat.19700050112 Some applications of the Taylor
% theory of polycrystal plasticity>, _Kristall und Technik_ 5 (1970),
% 145--175, gives the orientation-dependent Taylor factors and spin fields
% used in the final example.

%% Next
%
% Continue with <SO3Kernels.html Rotational Kernel Functions> to understand
% the localized basis functions used by the RBF representation listed on
% this page.

%#ok<*NOPTS,*NASGU>
