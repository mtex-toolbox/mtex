%% The Taylor Ambiguity
%
%%
% Plastic deformation in crystalline materials is primarily accommodated by
% crystallographic slip along specific slip systems. The Taylor model is a
% classical mean-field approach to describe the plastic response of
% polycrystalline aggregates.
%
% Taylor assumption: each grain is subjected to the same macroscopic strain tensor.
% Consequently, the deformation is assumed to be homogeneous across all grains
% and grain–grain interactions are neglected.
%
%% Description of the Taylor Model
%
% We have the following setting:
%
% * a set of $n\in\mathbb{N}$ slip systems (each consisting of a slip plane with normal vector $\vec n_{s}$ and a slip direction $\vec m_{s}$)
% * $\boldsymbol{\varepsilon}\in\mathbb{R}^{3\times3}$ - macroscopic strain tensor applied to each grain (2nd order symmetric tensor) 
% * $\mathbf{R}\in\mathrm{SO}(3)$ - crystal orientation of the considered grain
% * $\tau_s > 0$ - critical resolved shear stress of slip system $s$ (threshold stress required to activate slip)
%

% define the slip systems in fcc
cs = crystalSymmetry('m-3m');
sS = slipSystem.fcc(cs);

% slip Systems and critical resolved sheer stress
sSys = sS.symmetrise('antipodal')

% plane strain
q = 0.5;
epsilon = strainTensor(diag([-q 2*q -q]))

% orientation
ori = orientation.byAxisAngle(zvector,90*degree,cs)

%%
% The Taylor model determines the shear rates $\dot\gamma = (\dot\gamma_{s})_{s=1}^{n}$ 
% on the individual slip systems by solving the constrained minimization problem
%
% $$ \min_{\dot\gamma_{1},\dots,\dot\gamma_{n}} \sum_{s=1}^{n} \tau_{s} \cdot \abs{\dot\gamma_{s}} \qquad \text{s.t.} ~ \sum_{s=1}^{n}\dot\gamma_{s} \cdot P_{s} = \mat R^{-1}\boldsymbol{\varepsilon} $$ 
%
% where 
% 
% $$ P_{s} = \frac12 (\vec m_{s}\otimes \vec n_{s} + \vec n_{s} \otimes \vec m_{s}) $$ 
%
% denotes the symmetric Schmid tensor associated with slip system $s$.
% This tensor describes the contribution of the slip system to the plastic
% strain when it is activated. The tensor $\mat R^{-1}\boldsymbol{\varepsilon}$
% represents the imposed strain expressed in crystal coordinates.
%
%%
% The Taylor factor is defined as 
% $ M = \frac{1}{\|\boldsymbol{\varepsilon}\|} \sum_{s=1}^{n} \tau_{s} \, |\dot\gamma_{s}| $. 
% 
%%
% The spin tensor is given by
% $ W(\mat R) = \sum_{s=1}^{n} \dot\gamma_{s}(\mat R) \, Q_{s}, $ 
% where
% $ Q_{s} = \frac12 (\vec m_{s}\otimes \vec n_{s} - \vec n_{s} \otimes \vec m_{s}) $ 
% denotes the antisymmetric Schmid tensor associated with slip system $s$.
%

[M,~,W] = calcTaylor(ori.inv*epsilon,sS)

%%
% Note that, although the Taylor factor is uniquely determined, the
% corresponding minimizer $\dot\gamma$ is not necessarily unique.
% As a consequence, the resulting spin tensor may also be non-unique.
%
%% Computational Details
%
% The constraints are linear. Vectorizing the symmetric Schmid tensors
% and the right-hand side yields the linear system $\mat P \cdot \vec{\gamma} = b$,
% where $P \in \mathbb{R}^{9\times n}$.
%
% Since the Schmid tensors $P_s$ as well as the right-hand side are symmetric,
% three of the nine equations are duplicated. Moreover, plastic deformation
% due to crystallographic slip is volume preserving, i.e., the strain tensor
% has zero trace. Hence, one of the remaining six equations is redundant.
%
% Consequently, the matrix $P$ has rank 5 and the linear system can be
% reduced to a system with $P \in \mathbb{R}^{5\times n}$.

epsC = ori.inv*epsilon;
ind = [1,2,3,5,6];
b = epsC.M(ind)

sSeps = sSys.deformationTensor;
P = reshape(matrix(sSeps.sym),9,[]);
P = P(ind,:)

%%
% The minimizers $\vec{\gamma}$ of this linear system form an affine linear
% subspace of dimension $n-5$ in $\mathbb{R}^n$.
% Geometrically, this can be interpreted as a high-dimensional analogue
% of a plane in three-dimensional space.
% The minimization problem computes the solution that is, in some sense,
% closest to the coordinate center.
%
%%
% In general, the minimizer is not unique. This is called Taylor ambiguity.
% The set of all minimizers forms a convex polyhedron. Moreover, the edges 
% of this polyhedron lie on coordinate planes, so that at most five 
% components of $\vec{\gamma}$ are nonzero.
%
% This polyhedron can be characterized by computing all of its edges.
% In our example, we need to analyze $\binom{12}{5} = 792$ linear systems,
% of which only 384 have full rank 5.

% edges of the polyhedron of all minimizer
[~,gamma,spin] = calcTaylorAmbiguity(ori.inv*epsilon,sS);
gamma = gamma{1}'

%%
% According to the Taylor model, it is not clear which point within the
% convex hull corresponds to the desired spin tensor. Possible choices are,
% for instance, the mean or an inverse-distance weighted mean.

% compute the mean spin tensor
[~,gamma,spin] = calcTaylorAmbiguity(ori.inv*epsilon,sS,'mean')

% compute the inverse-distance weighted spin tensor
[~,gamma,spin] = calcTaylorAmbiguity(ori.inv*epsilon,sS,'inverseDistance')

%%
% Note that the feasibility of this computational approach strongly depends
% on the chosen slip-system set. For large sets, for instance body-centered 
% cubic (bcc) with the cubic symmetry above, we obtain 96 slip systems and 
% thus $\binom{48}{5} \approx 1.7$ million linear systems. 
% Therefore, analyzing all of these systems for every orientation
% becomes computationally expensive.
%
%
%% Orientation dependent Taylor factor and spin tensor
% We can compute a unique solution by taking the mean point of the convex
% polyhedron as spin tensor. This provides a simple and robust way to
% resolve the Taylor ambiguity. In this case, the resulting spin tensor
% represents the average lattice rotation over all admissible solutions.
%
% We plot this spin tensor orientation dependent together with the Taylor
% factor.

% Taylor model
[M,b,W] = calcTaylorAmbiguity(epsilon,sS,'mean')

% for plotting
ipfSec = ipfSections(cs,'sections',1);
ipfSec.r1 = yvector; ipfSec.r2 = zvector;

% plot Taylor factor and spin tensor
plotSection(M,ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexColorbar
hold on
plot(W,'add2all','linewidth',1,'color','k','arrowSize',1,'resolution',1.5*degree)
hold off

%%
% The spin tensor obtained in this way is generally not continuous.
% Discontinuities occur at orientations where the set of active slip
% systems changes, i.e., where a different vertex of the solution simplex
% becomes optimal.

plotSection(norm(W),ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexTitle('norm of spin tensor')
nextAxis
X = SO3FunHandle(@(r) W.eval(r).x,cs);
plotSection(X,ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexTitle('x-component of spin tensor')
nextAxis
Y = SO3FunHandle(@(r) W.eval(r).y,cs);
plotSection(Y,ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexTitle('y-component of spin tensor')
nextAxis
Z = SO3FunHandle(@(r) W.eval(r).z,cs);
plotSection(Z,ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexTitle('z-component of spin tensor')
setColorRange tight

%% Compute the spin tensor by a regularized Taylor model
% Instead of computing all solutions (i.e., resolving the ambiguity
% explicitly), we can modify the objective functional of the Taylor model
% by adding a quadratic regularization term with parameter $\lambda > 0$:
%
% $$ \min_{\dot\gamma_{1},\dots,\dot\gamma_{n}} \sum_{s=1}^{n} \tau_{s} \cdot \abs{\dot\gamma_{s}} + \lambda \dot\gamma_s^2 \qquad \text{s.t.} ~ \sum_{s=1}^{n}\dot\gamma_{s} \cdot P_{s} = \mat R^{-1}\boldsymbol{\varepsilon} $$ 
%
% The quadratic regularization term makes the objective strictly convex.
% Hence, the optimization problem admits a unique solution even though the
% linear constraints define an affine subspace of admissible shear rates.

% Do not compute the harmonic expansion to examine the continuity of the spin tensor
[M,~,W] = calcTaylorAmbiguity(epsilon,sS,'regularize',1e-6,'noharmonic')

% plot Taylor factor and spin tensor
plotSection(M,ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexColorbar
hold on
plot(W,'add2all','linewidth',1,'color','k','arrowSize',1,'resolution',1.5*degree)
hold off


%%
% Plot the spin tensor and its individual components. 

plotSection(norm(W),ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexTitle('norm of spin tensor')
nextAxis
X = SO3FunHandle(@(r) W.eval(r).x,cs);
plotSection(X,ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexTitle('x-component of spin tensor')
nextAxis
Y = SO3FunHandle(@(r) W.eval(r).y,cs);
plotSection(Y,ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexTitle('y-component of spin tensor')
nextAxis
Z = SO3FunHandle(@(r) W.eval(r).z,cs);
plotSection(Z,ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexTitle('z-component of spin tensor')
setColorRange tight


%% Taylor Ambiguity – The Solution Polyhedron
% We can also compute an orientation-dependent function that gives the
% number of vertices of the corresponding solution polyhedron.
%
% Additionally, we plot the spin tensors associated with all vertices of
% this polyhedron. The set of admissible spin tensors is given by all convex
% combinations of these vertex solutions.
%
% The arrows therefore represent the spin tensors of the extremal
% solutions, while the color map indicates how many such vertices exist
% for the corresponding orientation.

[~,b,~] = calcTaylorAmbiguity(epsilon,sS);
NoE = SO3FunHandle(@(rot) cellfun(@(x) size(x,1), b(rot)));

plotSection(NoE,ipfSec,'projection','stereo','resolution',0.15*degree,'noGrid')
mtexColorbar
hold on
plotTaylorSpinVectors( epsilon,sS.symmetrise, ipfSec,'projection','stereo','resolution',5*degree,'color','black','arrowSize',3)
hold off
mtexTitle('Plot the spin tensors of all solutions onto the number of active vertices.')





%%
%
%
%

function plotTaylorSpinVectors(epsilon,sS,varargin)

sS = sS.ensureSymmetrised;
[~,~,W_All] = calcTaylorAmbiguity(epsilon,sS);

oS = newODFSectionPlot(sS.CS,epsilon.CS,varargin{:});
S3G0 = oS.quiverGrid('resolution',15*degree,varargin{:});
W = W_All(S3G0);

v = cat(1,W{:});
ori0 = repelem(S3G0, cellfun(@length, W)).';

if check_option(varargin,'normalize')
  v = normalize(v);
else
  v = v ./ max(norm(v(:)));
end

ori1 = exp(ori0,v/10000,SO3TangentSpace.leftSpinTensor);
oS.quiver(ori0, ori1,'noSymmetry',varargin{:},'all');

end
