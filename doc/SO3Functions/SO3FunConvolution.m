%% Convolution of Orientational Dependent and Spherical Functions
%
%%
% On this page we will show how the convolution of <SO3Fun.SO3Fun.html
% |ODFs (SO3Fun's)|>, <S2Fun.S2Fun.html |Spherical functions (S2Fun's)|>,
% <SO3Kernels.html |SO3Kernel's|> and <S2Kernels.html |S2Kernel's|>
% is defined.
%
% The convolution is a integral operator which has several slightly
% different definitions.
% It is often used to smooth functions or compute there cross correlation.
%
%%
% We have to distinguish which objects are convoluted.
%
% * <SO3FunConvolution.html#3 Convolution of two SO3Fun's>
% * <SO3FunConvolution.html#8 Convolution of two S2Fun's>
% * <SO3FunConvolution.html#10 Convolution of a SO3Fun and a S2Fun>
% * <SO3FunConvolution.html#13 Convolution with SO3Kernel's and SO2Kernel's>
%
%% Convolution of two rotational functions
%
% Here we distinguish two definitions. They are named the left $*_L$ and 
% right $*_R$ sided convolution.
% 
% * The left sided convolution (default)* 
%
% Let two |SO3Fun's| $f \colon {}_{S_L } \backslash SO(3)
% /_{S_x} \to \mathbb{C}$ where $S_L$ is the left symmetry and $S_x$ is
% the right symmetry and $g: {}_{S_x} \backslash SO(3) /_{S_R} \to \mathbb
% C$ where $S_x$ is the left symmetry and $S_R$ is
% the right symmetry be given. 

ss = specimenSymmetry;
cs = crystalSymmetry('222');
f = SO3FunRBF(orientation.rand(ss,cs))
g = SO3FunHarmonic.example

%% 
% Then the convolution $f {*}_L g \colon {}_{S_L} \backslash SO(3) /_{S_R} \to \mathbb C$
% is defined by
%
% $$ (f {*}_L g)(R) = \frac{1}{8\pi^2} \int_{SO(3)} f(q) \cdot g(q^{-1}\,R) \, dq $$
%
% where the right symmetry of $f$ have to coincide with the left symmetry of $g$.
% The normalization factor of the integral reads as 
% $vol(SO(3)) = \int_{SO(3)} 1 \, dR = 8\pi^2$. 

c = conv(f,g)

% Test
r = orientation.rand(c.CS,c.SS);
c.eval(r)
mean(SO3FunHandle(@(q) f.eval(q).*g.eval(inv(q).*r)))

%%
% Note that the left sided convolution $*_L$ is used as default in MTEX. 
%
% * The right sided convolution*
%
% As contrast we have the second definition:
%
% Let two |SO3Fun's| $f \colon {}_{S_x } \backslash SO(3)
% /_{S_R} \to \mathbb{C}$ where $S_x$ is the left symmetry and $S_R$ is
% the right symmetry and $g: {}_{S_L} \backslash SO(3) /_{S_x} \to \mathbb
% C$ where $S_L$ is the left symmetry and $S_x$ is the right symmetry be given. 

ss = specimenSymmetry;
cs = crystalSymmetry('222');
f = SO3FunHarmonic.example
g = SO3FunRBF(orientation.rand(ss,cs))

%%
% The convolution $f {*}_R g \colon {}_{S_L}\backslash SO(3) /_{S_R} \to \mathbb{C}$
% is defined by
%
% $$ (f {*}_R g)(R) = \frac1{8\pi^2} \int_{SO(3)} f(q) \cdot g(R\,q^{-1}) \, dq $$
%
% where the left symmetry of $f$ have to coincide with the right symmetry of $g$.

c = conv(f,g,'right')

% Test
r = orientation.rand(c.CS,c.SS);
c.eval(r)
mean(SO3FunHandle(@(q) f.eval(q).*g.eval(r.*inv(q))))

%%
% The convolution of matrices of SO3FunHarmonic's with matrices of SO3Functions 
% works elementwise, see at <SO3FunMultivariate.html multivariate SO3Fun's>
% for there definition.
%

%% Convolution of two spherical functions
%
% Consider there are two |S2Fun's| $f: \mathbb S^2 /_{S_R} \to \mathbb{C}$
% $g: \mathbb S^2 /_{S_L} \to \mathbb{C}$ given, where $S_R$ and $S_L$ 
% denotes the symmetries.

cs = crystalSymmetry;
f = S2FunHarmonicSym(S2Fun.smiley,cs)
g = S2FunHarmonic(S2DeLaValleePoussinKernel)

%%
% Then the spherical convolution yields a orientation dependent function
% $f*g: {}_{S_L} \backslash SO(3) /_{S_R} \to \mathbb{C}$ with right 
% symmetry $S_R$ and left symmetry $S_L$. The convolution is defined by
%
% $$ (f * g)(R) = \frac1{4\pi} \int_{S^2} f(R^{-1}\xi) \cdot g(\xi) \, d\xi. $$
%
% The normalization factor of the integral reads as 
% $vol(S^2) = \int_{S^2} 1 \, d\xi = 4\pi$. 

c = conv(f,g)

% Test
r = orientation.rand(c.CS,c.SS);
c.eval(r)
c2 = S2FunHandle(@(v) f.eval(inv(r)*v).*g.eval(v));
v = equispacedS2Grid('resolution',0.2*degree);
mean(c2.eval(v))

%% Convolution of a rotational function with a spherical function
%
% We consider a |SO3Fun|  $f: {}_{S_h} \backslash SO(3) /_{S_R}
% \to \mathbb{C}$ with left symmetry $S_h$ and right symmetry $S_R$ and a
% |S2Fun| $h \colon \mathbb S^2 /_{S_h} \to \mathbb C$ with symmetry group 
% $S_h$.

f = SO3FunHarmonic.example
h = S2FunHarmonicSym(S2Fun.smiley,ss)

%%
% The convolution yields a |S2Fun| $f*h \colon \mathbb S^2/_{S_R} \to
% \mathbb C$. In MTEX it is defined by 
%
% $$ (f * h)(\xi) =  \frac1{8\pi^2} \int_{SO(3)} f(q) \cdot h(q\,\xi) \, dq. $$
%

c = conv(f,h)

% Test
v = Miller.rand(c.CS);
c.eval(v)
mean(SO3FunHandle(@(q) f.eval(q).*h.eval(q*v)))

%%
% If you want to compute the convolution of $f: {}_{'1'} \backslash SO(3) /_{S_R}
% \to \mathbb{C}$ and $h \colon \mathbb S^2 /_{S_R} \to \mathbb C$ which
% yields $f*h \colon \mathbb S^2/_{S_R} \to \mathbb C$ and is defined as
%
% $$ (f * h)(\xi) =  \frac1{8\pi^2} \int_{SO(3)} f(q) \cdot h(q^{-1}\,\xi) \, dq. $$
%

f = SO3FunHarmonic.example
h = S2FunHarmonicSym(S2Fun.smiley,f.CS)

c = conv(inv(f),h)

% Test
v = vector3d.rand;
c.eval(v)
mean(SO3FunHandle(@(q) f.eval(q).*h.eval(inv(q)*v)))

%% Convolution with kernel function
% 
% * rotational kernel functions * 
%
% Since <SO3Kernels.html |SO3Kernel's|> are special orientation dependent
% functions we can easily describe them as |SO3Fun's|. Hence the
% convolution with <SO3Kernels.html |SO3Kernel's|> is exactly the same as
% above.
% 
% Note that <SO3Kernels.html |SO3Kernel's|> are radial basis
% functions which only depends on the rotation angle $\omega$.
% Since the rotation angle of two matrices satisfies 
% $\omega(q^{-1}\,R)=\omega(R\,q^{-1})$, the left and right sided 
% convolution are equivalent by convoluting with |SO3Kernels|. Moreover the
% convolution is commutative in this case.
%

f = SO3FunHarmonic.example
psi = SO3DeLaValleePoussinKernel

c = conv(f,psi)

%%
%
% * spherical kernel functions * 
%
% Let a spherical kernel function $\psi(\vec v \cdot \vec e_3)$ be defined
% as in <S2Kernels.html |S2Kernel's|>. Then the convolution with a @S2Fun reads as
%
% $$ (f * \psi) (\vec v) = \frac1{4\pi} \int_{S^2} f(\xi) \, \psi(\xi \cdot \vec v) \, d\xi. $$
%
% Note that <S2Kernels.html |S2Kernel's|> are special spherical functions.
% Hence we can easily describe them as |S2Fun's| and convolute them as
% described above for convolution of two spherical functions
%
% $$ (f * \psi) (R) = \frac1{4\pi} \int_{S^2} f(R^{-1}\,\xi) \, \psi(\xi \cdot \vec e_3) \, d\xi. $$
%
% The first formula yields a @S2Fun while the second formula yields a @SO3Fun.
% They are equal for $\vec v = R^{-1} \vec e_3$.
%

% Test
f = S2Fun.smiley
psi = S2DeLaValleePoussinKernel

c1 = conv(f,psi)

% Test
v = vector3d.rand;
c1.eval(v)
xi = equispacedS2Grid('resolution',0.2*degree);
mean(f.eval(xi).*psi.eval(cos(angle(xi,v).')))

% compare with spherical convolution
r = rotation.map(v,zvector);
h = S2FunHarmonic(psi);
c2 = conv(f,h);
c2.eval(r)
mean(f.eval(inv(r)*xi).*h.eval(xi))

