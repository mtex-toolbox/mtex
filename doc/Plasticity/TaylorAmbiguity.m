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
[~,gamma,spin] = calcTaylorNew(ori.inv*epsilon,sS);
gamma = gamma{1}'

%%
% According to the Taylor model, it is not clear which point within the
% convex hull corresponds to the desired spin tensor.

% use the mean spin tensor
[~,gamma,spin] = calcTaylorNew(ori.inv*epsilon,sS,'mean')

%%
% Note that the feasibility of this computational approach strongly depends
% on the chosen slip system. For large slip-system sets, for instance
% body-centered cubic (bcc) with the cubic symmetry above, we obtain 96 
% slip systems and thus $\binom{48}{5} \approx 1.7$ million linear systems.
%
%


%% Compute 
% We can compute a unique solution by taking the mean point of the convex
% polyeder as spin tensor.
% Therefore the Taylor factor and spin tensor look like:
%

% Taylor model
[M,b,W] = calcTaylorNew(epsilon,sS,'mean')

% for plotting
ipfSec = ipfSections(cs,'sections',1);
ipfSec.r1 = yvector; ipfSec.r2 = zvector;

plotSection(M,ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
mtexColorbar
hold on
% plot(W,ipfSec,'projection','stereo','resolution',0.2*degree,'noGrid')
plot(W,'add2all','linewidth',1,'color','k','arrowSize',1,'resolution',1.5*degree)
hold off

%%
% We can also compute a function which gives us the number of edges of the
% corresponding solution simplex.
% 


[~,b,~] = calcTaylorNew(epsilon,sS);
NoE = SO3FunHandle(@(rot) cellfun(@(x) size(x,1), b(rot)));

plotSection(NoE,ipfSec,'projection','stereo','resolution',0.15*degree,'noGrid')
mtexColorbar


%%
%
%
%
%
