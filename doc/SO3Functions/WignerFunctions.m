%% Wigner-D functions
%
%% Theorie
%
% The Wigner-D functions are special functions on the rotation group
% $SO(3)$.
%
% In terms of Matthies (ZYZ-convention) Euler angles ${\bf R} = {\bf
% R}(\alpha,\beta,\gamma)$ the $L_2$-normalized Wigner-D function of degree
% $n$ and orders $k,l \in \{-n,\dots,n\}$ is defined by
%
% $$ D_n^{k,l}({\bf R}) = \sqrt{2n+1} \, \mathrm e^{-\mathrm i k\gamma}
% \mathrm d_n^{k,l}(\cos\beta) \,e^{-\mathrm i l\alpha} $$
%
% where $d_n^{k,l}$, denote the real valued Wigner-d functions, which are
% defined in terms of Jacobi polynomial $P_s^{a,b}$  by
% 
% $$ d_n^{k,l}(x) = (-1)^{\nu} \binom{2n-s}{s+a}^{\frac12}
% \binom{s+b}{b}^{-\frac12} \left(\frac{1-x}{2}\right)^{\frac{a}{2}}
% \left(\frac{1+x}{2}\right)^{\frac{b}2} P_s^{a,b}(x)$$
% 
% using the constants $a =|k-l|$, $b =|k+l|$, $s = n - \max\{|k|,|l|\}$ and
% $\nu = \min\{0,k\}+\min\{0,l\}$ if $l \geq k$; $\nu =
% \min\{0,k\}+\min\{0,l\} + k+l$ otherwise.
%
% This definition is slightly different to other well known definitions,
% because the Wigner-D functions are defined compatible to the
% <SphericalHarmonics.html spherical harmonics> which form an orthonormal
% basis on the 2-sphere.
%
%% 
% In MTEX the Wigner-D and Wigner-d functions are available through the
% command <Wigner_D.html |Wigner_D|>

% the Wigner-d function of degree 1
beta = 0.5;
d = Wigner_D(1,beta)

% the Wigner-D function of degree 1
R = rotation.rand;
D = sqrt(3) * Wigner_D(1,R)

%%
% Here the orders $k$, $l$ work as row and column indices.
%
%% Series Expansion
%
% The Wigner-D functions form an orthonormal basis in $L_2(SO(3))$. Hence,
% we can describe functions on the rotation group $SO(3)$ by there harmonic
% representation using the class <SO3FunHarmonicRepresentation.html |SO3FunHarmonic|>.
%
% Hence we define the Wigner-D function $D_1^{1,-1}$ by

D = SO3FunHarmonic([0;0;0;1])
D.eval(R)

%%
% Various normalization for the Wigner-D functions are common in the
% literature.
%
% Here we define the $L_2$-norm by
%
% $$ \| f \|_2 = \left(\frac1{8\pi^2}\,\int_{SO(3)} \lvert f( {\bf R}) \rvert^2 \,\mathrm d {\bf R} \right)^{1/2} $$
%
% such that the norm of the constant function $f=1$ is $1$. Take a look on the section 
% <SO3FunOperations.html#6 Integration of SO3Fun's>.
%
% Using that definition the Wigner-D functions in MTEX are normalized, i.e. $\|
% D_n^{k,l} \|_2 = 1$ for all $n,k,l$.


norm(D)

%% Some important formulas for Wigner-D functions
%
% The Wigner-D functions are the matrix elements of the representations
% $D_n \colon SO(3) \to \mathbb C^{(2n+1)\times(2n+1)}$ on $SO(3)$. 
% Since representations are group homomorphisms, we have
% $D_n( {\bf R} \, {\bf Q} ) = \frac1{\sqrt{2n+1}} \, D_n( {\bf Q} ) \, D_n( {\bf R} ).$
% Hence we get
% 
% $$ D_n^{k,l}( {\bf R} \, {\bf Q} ) = \frac1{2n+1} \sum_{j=-n}^n D_n^{k,j}( {\bf Q} )\,D_n^{j,l}( {\bf R} ). $$
%
%%
% Some symmetry properties of Wigner-D functions yields
%
% $$ D_n^{k,l}( {\bf R} ) = \overline{D_n^{l,k}( {\bf R}^{-1} )}. $$
%

%% Symmetry properties of Wigner-d functions
% 
% The Wigner-d functions by construction fulfill a lot of symmetry 
% properties. Some important are
%  
% $$ d_n^{k,l}(x) = d_n^{-k,-l}(x) = (-1)^{k+l}\, d_n^{l,k}(x) = (-1)^{k+l}\, d_n^{-l,-k}(x)$$
% 
% $$ d_n^{k,l}(x) = (-1)^{n+k+l}\,d_n^{-k,l}(-x) = (-1)^{n+k+l}\,d_n^{k,-l}(-x) $$
%
% $$d_n^{k,l}(\cos\beta) = (-1)^{k+l}\,d_n^{k,l}(\cos(-\beta))$$
%

%#ok<*NASGU>