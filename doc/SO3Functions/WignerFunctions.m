%% Wigner-D functions
%
% Wigner-D functions play the role of sine and cosine waves for rotations.
% Weighted sums of them can represent any square-integrable function on the
% rotation group $\mathrm{SO}(3)$.
%
% Each function has a non-negative *degree* $n$ and two *orders* $k$ and
% $l$, both between $-n$ and $n$. The command <WignerD.html |WignerD|>
% evaluates a complete matrix of orders at once.

%#ok<*NASGU>

%% Evaluate one degree
%
% A real number passed to |WignerD| is the second Euler angle $\beta$.
% The result below contains all Wigner-d functions of degree one at
% $\beta=90$ degrees.

beta = 90 * degree;
d = WignerD(beta,1)

%%
% The rows and columns correspond to $k=-1,0,1$ and $l=-1,0,1$,
% respectively. In particular, the central value is zero at 90 degrees,
% while the corner values have magnitude $0.5$.
%
% Passing a rotation instead evaluates the generally complex Wigner-D
% functions. The |'normalize'| flag selects MTEX's $L_2$ normalization.

R = rotation.byEuler(20*degree,40*degree,10*degree);
W = WignerD(R,1,'normalize')

%% Follow the Wigner-d curves
%
% The Wigner-d functions are ordinary functions of the single angle
% $\beta$, so they can be drawn directly. Here are three entries from the
% degree-one matrix.

beta = linspace(0,pi,181);
d = zeros(numel(beta),3);
for j = 1:numel(beta)
  Dj = WignerD(beta(j),1);
  d(j,:) = [Dj(1,1) Dj(2,2) Dj(1,3)];
end

plot(beta./degree,d,'linewidth',2)
xlim([0 180]); xlabel('beta in degree')
legend('d^1_{-1,-1}','d^1_{0,0}','d^1_{-1,1}', ...
  'location','best')

%%
% The first curve decreases from 1 to 0. The central curve crosses zero at
% 90 degrees, while the corner entry decreases from 0 to -1. These smooth
% shapes arise because the functions are polynomials in
% $\cos(\beta/2)$ and $\sin(\beta/2)$. Series in Wigner-d functions
% therefore converge quickly for smooth functions.

%% Build one basis function
%
% The Wigner-D functions form an orthonormal basis of
% $L_2(\mathrm{SO}(3))$. MTEX stores a weighted series in this basis as an
% <SO3FunHarmonicRepresentation.html |SO3FunHarmonic|> object.
%
% Its coefficient vector starts with the degree-zero block. The next nine
% entries are the degree-one matrix, stored one column at a time. The vector
% below therefore selects $D_1^{1,-1}$.

F = SO3FunHarmonic([0;0;0;1]);
seriesValue = F.eval(R)

%%
% The selected coefficient is row 3 and column 1 of the normalized matrix
% |W| above. Both evaluations give approximately |0.1995 + 0.0352i|.

directValue = W(3,1)
comparisonError = abs(seriesValue-directValue)

%% Normalization
%
% Several normalizations of Wigner-D functions occur in the literature.
% MTEX defines the $L_2$ norm by
%
% $$ \|f\|_2 = \left(\frac{1}{8\pi^2}\int_{\mathrm{SO}(3)}
% \lvert f(\mathbf{R})\rvert^2\,\mathrm{d}\mathbf{R}\right)^{1/2}. $$
%
% With this measure, the constant function $f=1$ has norm 1. Every
% normalized Wigner-D function also has
% $\|D_n^{k,l}\|_2=1$.

norm(F)

%%
% The section <SO3FunOperations.html#13 Integration and Norms> explains
% integration and norms for rotational functions in more detail.

%% The maths behind Wigner-D functions
%
% In the Matthies ZYZ convention, write a rotation as
% $\mathbf{R}=\mathbf{R}(\alpha,\beta,\gamma)$. MTEX defines the
% $L_2$-normalized Wigner-D function by
%
% $$ D_n^{k,l}(\mathbf{R})=\sqrt{2n+1}\,
% \mathrm{e}^{-\mathrm{i}k\gamma}\,d_n^{k,l}(\beta)\,
% \mathrm{e}^{-\mathrm{i}l\alpha}. $$
%
% The real-valued Wigner-d function
% $d_n^{k,l}\colon[0,\pi]\to\mathbb{R}$ is defined through the Jacobi
% polynomial $P_s^{a,b}$ by
%
% $$ d_n^{k,l}(\beta)=(-1)^\nu
% \binom{2n-s}{s+a}^{\frac{1}{2}}
% \binom{s+b}{b}^{-\frac{1}{2}}
% \left(\frac{\sin\beta}{2}\right)^a
% \left(\frac{\cos\beta}{2}\right)^b
% P_s^{a,b}(\cos\beta), $$
%
% where $a=|k-l|$, $b=|k+l|$, and
% $s=n-\max\{|k|,|l|\}$. The sign exponent is
%
% $$ \nu=\begin{cases}
% \min\{0,k\}+\min\{0,l\}, & \text{if }l\geq k,\\
% \min\{0,k\}+\min\{0,l\}+k+l, & \text{otherwise}.
% \end{cases} $$

%% How the MTEX convention differs
%
% MTEX's definition differs slightly from other common definitions. It is
% compatible with the <SphericalHarmonics.html spherical harmonics>, which
% form an orthonormal basis on the 2-sphere and are used to build
% <S2FunHarmonicRepresentation.html harmonic spherical functions>.
%
% * The orders $k$ and $l$ are interchanged in the exponential factors
% compared with common definitions.
% * The factor $\sqrt{2n+1}$ gives each $D_n^{k,l}$ unit $L_2$ norm.
% * The sign of $d_n^{k,l}$ includes the contribution
% $\min\{0,k\}+\min\{0,l\}$ through $(-1)^\nu$.
% * MTEX parametrizes a Wigner-d function by the second Euler angle
% $\beta$. Thus MTEX's $d_n^{k,l}(\beta)$ corresponds to
% $d_n^{k,l}(x)$ with $x=\cos(\beta)$ in definitions that use $x$.

%% Composition and symmetry
%
% For each degree $n$, the Wigner-D functions are the matrix elements of a
% representation $D_n\colon\mathrm{SO}(3)\to
% \mathbb{C}^{(2n+1)\mathbin{\times}(2n+1)}$. The representation is a group
% homomorphism. With MTEX's order and normalization conventions,
%
% $$ D_n(\mathbf{R}\mathbf{Q})=\frac{1}{\sqrt{2n+1}}
% D_n(\mathbf{Q})D_n(\mathbf{R}), $$
%
% and hence
%
% $$ D_n^{k,l}(\mathbf{R}\mathbf{Q})=
% \frac{1}{\sqrt{2n+1}}\sum_{j=-n}^{n}
% D_n^{k,j}(\mathbf{Q})D_n^{j,l}(\mathbf{R}). $$
%
% Inversion exchanges the two orders and complex conjugates the value:
%
% $$ D_n^{k,l}(\mathbf{R})=
% \overline{D_n^{l,k}(\mathbf{R}^{-1})}. $$
%
% The Wigner-d functions also satisfy several useful symmetries:
%
% $$ d_n^{k,l}(\beta)=d_n^{-k,-l}(\beta)
% =(-1)^{k+l}d_n^{l,k}(\beta)
% =(-1)^{k+l}d_n^{-l,-k}(\beta), $$
%
% $$ d_n^{k,l}(\beta)=(-1)^{n+k+l}d_n^{-k,l}(\pi-\beta)
% =(-1)^{n+k+l}d_n^{k,-l}(\pi-\beta), $$
%
% $$ d_n^{k,l}(\beta)=(-1)^{k+l}d_n^{k,l}(-\beta). $$

%% References
%
% * D. A. Varshalovich, A. N. Moskalev, and V. K. Khersonskii,
% <https://doi.org/10.1142/0270 _Quantum Theory of Angular Momentum_>,
% World Scientific, 1988, gives common Wigner-D definitions against which
% MTEX's order, sign, and normalization conventions can be compared.
