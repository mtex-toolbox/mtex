%% Wigner-D functions
%
%%
% The Wigner-D functions are special functions on the rotation group $SO(3)$.
%
% In terms of Matthies (ZYZ-convention) Euler angles 
% ${\bf R} = ${\bf R}(\alpha,\beta,\gamma)$ the $L_2$-normalized Wigner-D 
% function of degree $n\in\mathbb N$ and orders $k,l \in \{-n,\dots,n\}$ is
% defined by
%
% $$ D_n^{k,l}({\bf R}) = \sqrt{2n+1} \, \mathrm e^{\mathrm i k\gamma} \mathrm d_n^{k,l}(\cos\beta) \,e^{\mathrm i l\alpha} $$
%
% where $d_n^{k,l}$, denotes the real valued Wigner-d function, which is
% defined by some constants
%
% $$ a &=|k-l|,\\
% b &=|k+l|,\\
% s &= n- \frac{a+b}2 = n - \max\{|k|,|l|\},\\
% \nu &= \min\{0,k\}+\min\{0,l\}+
%         \begin{cases}
%           0 	& \text{falls } l \geq k,\\
%           k+l & \text{sonst}
%         \end{cases} $$
%
% and the formula
%
% $$ d_n^{k,l}(x) = (-1)^{\nu} \binom{2n-s}{s+a}^{\frac12} \binom{s+b}{b}^{-\frac12} \left(\frac{1-x}{2}\right)^{\frac{a}2} \left(\frac{1+x}{2}\right)^{\frac{b}2} P_s^{a,b}(x)$$
%
% were $P_s^{a,b}$ denotes the corresponding Jacobi polynomial of degree $s$.
%
% This definition is slightly different to other well known definitions,
% because the Wigner-D functions are defined compatible to the 
% <SphericalHarmonics.html spherical harmonics> which form an orthonormal
% basis on the 2-sphere.
%
%%
% We define the real valued Wigner-d functions of degree 1 by

R = rotation.rand
[alpha,beta,gamma] = Euler(R,'Matthies')
d = Wigner_D(1,beta)

%%
% where the orders $k,l$ work as row and column indices.
%
% Similary we get the function values of the Wigner-D functions of degree 1
% in a rotation $R$ by the command |Wigner_D| and the normalization factor 
% $\sqrt{2n+1}$, i.e.

R = rotation.rand
sqrt(3)*Wigner_D(1,R)

%%
% The Wigner-D functions form an orthonormal basis in $L_2(SO(3))$.
% Hence we describe functions on $SO(3)$ by there harmonic
% representation using the class <SO3FunHarmonicRepresentation.html
% @SO3FunHarmonic>.
%
% With that we define the Wigner-D function $D_1^{1,-1}$ by

D = SO3FunHarmonic([0;0;0;1])
D.eval(R)

%%
% Various normalizations for the Wigner-D functions are common in the
% literature.
%
% Here we define the $L_2$-norm by
%
% $$ \lVert f \rVert_2 = \left(\frac1{8\pi^2}\,\int_{SO(3)} |f(R)|^2 \,\mathrm d R \right)^{1/2} $$
%
% such that $ \| 1 \|_2^2 = 1$. Take a look on the section 
% <SO3FunOperations.html#6 Integration of SO3Fun's>.
%
% Using that definition the Wigner-D functions in MTEX fulfill
%
% $$\| D_n^{k,l} \|_2 = 1$$
% 
% for all $n,k,l$.
%

norm(D)

%% Some important formulas for Wigner-D functions
%
% The Wigner-D functions are the matrix elements of the representations
% $D_n \colon SO(3) \to \mathbb C^{(2n+1)\times(2n+1)}$ on $SO(3)$. 
% Since representations are group homomorphisms, we have
% $D_n(RQ) = \frac1{\sqrt{2n+1}} \, D_n(Q) \, D_n(R)$.
% Hence we get
% 
% $$ D_n^{k,l}(R\,Q) = \frac1{2n+1} \sum_{j=-n}^n D_n^{k,j}(Q)\,D_n^{j,l}(R) $$.
%
%%
% Some symmetry properties of Wigner-D functions yields
%
% $$ D_n^{k,l}(R) = \overline{D_n^{l,k}(R^{-1})} $$.
%

%% Symmetry properties of Wigner-d functions
% 
% The Wigner-d functions by construction fulfill a lot of symmetry 
% properties. Some importants are
%  
% $$ d_n^{k,l}(x) &= d_n^{-k,-l}(x) = (-1)^{k+l}\, d_n^{l,k}(x) = (-1)^{k+l}\, d_n^{-l,-k}(x) \\
%    d_n^{k,l}(x) &= (-1)^{n+k+l}\,d_n^{-k,l}(-x) = (-1)^{n+k+l}\,d_n^{k,-l}(-x) \\
%    d_n^{k,l}(\cos\beta) &= (-1)^{k+l}\,d_n^{k,l}(\cos(-\beta))  $$
%
