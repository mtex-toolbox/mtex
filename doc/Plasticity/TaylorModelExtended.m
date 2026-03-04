%% Analyizing the Taylor Model
% 
%%
% Modelling plastic deformation, ...
% 
% Taylor assumption: each grain is subjected to the same macroscopic strain tensor
% This means: homogeneous deformation across all grains and neglecting grain interactions.
% 
%% Description of The Taylor Model
%
% We have the following setting:
% * a set of $n\in\IN$ slip systems (each consists of a slip plane with normal vector $\vec n_{s}$ and a slip direction $\vec m_{s}$)
% * $\boldsymbol{\eps}\in\IR^{3\times3}$ - macroscopic strain tensor (applied to any single grain)
% * $\mat R\in\SO3$ - crystal orientation of the considered grain
% * $\tau_{s}>0$ - critical resolved shear stress of slip system $s$ (represents the threshold stress required to activate slip)
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
% \begin{equation*}
%   \min_{\dot\gamma_{1},\dots,\dot\gamma_{n}} \sum_{s=1}^{n} \tau_{s} \cdot \abs{\dot\gamma_{s}}
%   \qquad \text{s.t.} ~
%   \sum_{s=1}^{n}\dot\gamma_{s} \cdot P_{s} = \mat R^{-1}\boldsymbol{\eps},
% \end{equation*}
% where $ P_{s} = \frac12 (\vec m_{s}\otimes \vec n_{s} + \vec n_{s} \otimes \vec m_{s}) $
% denotes the symmetric Schmid tensor associated with slip system $s$, 
% which describes the contribution of that system to the plastic strain when activated.
% $\mat R^{-1}\boldsymbol{\eps}$ is the plastic strain in crystal coordinates
%
%%
% The Taylor factor is defined by
% \[ M = \frac1{\norm{\boldsymbol\eps}}\sum_{s=1}^{n} \tau_{s} \cdot \abs{\dot\gamma_{s}} \]
% 
% The spin tensor is given by
% \[ \vec \Omega(\mat R) = \sum_{s=1}^{n}\dot\gamma_{s}(\mat R) \cdot Q_{s}, \]
% where
% \[ Q_{s} = \frac12 (\vec m_{s}\otimes \vec n_{s} - \vec n_{s} \otimes \vec m_{s}) \]
% denotes the antisymmetric Schmid tensor associated with slip system $s$.
%
%% Computational Details
%
% The constraints are linear. Vectorization of the symmetric Schmid tensors 
% and the right side yields the linear system $ \mat P \cdot \vec\gamma =b $,  
% where $P\in\mathbb{R}^{9\times n}$.
% Because, the Schmid tensors $P_s$ and also the right hand side are symmetric, 
% 3 equations occour twice. Furthermore, because of SummationsStressNullRegel , every of the remaining 6
% equations is exactly the sum of the other 5. Hence the matrix P has rank 5 and 
% the linear system from above can be reduced to $P \in \mathbb{R}^{5\times n}$.
%

epsC = ori.inv*epsilon;
ind = [1,2,3,5,6];
b = epsC.M(ind)

sSeps = sSys.deformationTensor;
P = reshape(matrix(sSeps.sym),9,[]);
P = P(ind,:)

%%
% Now, the solutions ($\vec \gamma$) of this linear system form a affine linear 
% subspace of dimension $n-5$ in the $\mathbb R^n$
% (Like a plane in 3-dimensional space, but with much more dimensions).
% The minimization problem computes the solution which is in some sense nearest 
% to the coordinate center.
%
% Generally, the solution of a linear problem is not necessarily unique. 
% The solutions form a convex polyhedron. 
% Furthermore, the edges of this polyhedron lie on the coordinate planes, such 
% that at most 5 coordinates are not zero.
% We can describe this polyhedron by computing all of this edges.
%

% List of all possible linear systems
ind = nchoosek(1:12,5);
ind = ind';
A = reshape(P(:,ind(:)),5,5,[]);
size(A)

% some of then are unfeasible (if rank<5)
s = pagesvd(A);
tol = 5 * eps(max(s, [], 1));
rank = sum(s>tol);
A = A(:,:,rank==5);
size(A)

% compute solution
gamma = pagemldivide(A,b.');

% corresponding Zielfunktionswert
M = sum(abs(gamma))./norm(epsC)

%%




calcTaylorNew(ori.inv*epsilon,sS)


