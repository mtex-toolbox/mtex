clear


%%
% -------------------------------------------------------------------------
% --------------------- Test SO3VectorFieldHarmonics ----------------------
% -------------------------------------------------------------------------


% construct Vector Fields
f = SO3Fun.dubna;
cs = f.CS;
ss = specimenSymmetry('222');
f.SS = ss;
g1 = f.grad;
g2 = g1.right;
h1 = g1.right('internTangentSpace');
h2 = h1.left;

%% Test left and right and constructor

% orientations
r1 = orientation.rand(cs);
r2 = orientation.rand(crystalSymmetry,ss);

% test
norm(g1.eval(r1.symmetrise) - h2.eval(r1.symmetrise))
norm(g2.eval(r2.symmetrise) - h1.eval(r2.symmetrise))

%% Test eval

% omit left symmetry
e = r2.symmetrise.inv .* g1.eval(r2.symmetrise);
norm(e-e(1))

% omit right symmetry
e = r1.symmetrise .* g2.eval(r1.symmetrise);
norm(e-e(1))


%% Test curl and antiderivative and gradient

% curl
norm(norm(g1.curl))
norm(norm(g2.curl))
norm(norm(h1.curl))
norm(norm(h2.curl))

% antiderivative
norm(g1.antiderivative+1-SO3FunHarmonic(f))
norm(g2.antiderivative+1-SO3FunHarmonic(f))
norm(h1.antiderivative+1-SO3FunHarmonic(f))
norm(h2.antiderivative+1-SO3FunHarmonic(f))

%% Test divergence

% left vs right div
norm(g1.div - g2.div)
norm(g1.div - h1.div)
norm(g1.div - g1.div('check'))

%% Test curl

g = SO3VectorFieldHarmonic(SO3FunHarmonic.example.*[1,2,3]);
h = g.right.curl;

r = symmetrise(orientation.rand(cs));
norm(norm ( r .* h.eval(r) - vector3d(g.curl(r)) ))


%% Test quadrature
clear

f = SO3Fun.dubna;
cs = f.CS;
ss = specimenSymmetry('222');
f.SS = ss;
% g = SO3VectorFieldHarmonic(f.*[1,2,3]);
g = f.grad;
g.bandwidth=20;

% Test 1
r = quadratureSO3Grid(20,cs);
v = g.eval(r);
h = SO3VectorFieldHarmonic.quadrature(r,v,'bandwidth',20,cs,ss);
norm(norm(h-g))

% Test 2
w = r.weights;
r = r.fullGrid;
v = g.eval(r);
h = SO3VectorFieldHarmonic.quadrature(v,'bandwidth',20,cs,ss,'weights',w);
norm(norm(h-g))

% Test 3
g.tangentSpace = 2;
r = quadratureSO3Grid(20,cs);
v = g.eval(r);
h = SO3VectorFieldHarmonic.quadrature(r,v,'bandwidth',20,cs,ss,SO3TangentSpace.leftSpinTensor);
norm(norm(h-g))

% Test 4
gr = g.right;
h = SO3VectorFieldHarmonic.quadrature(gr);
h = right(left(h,'internTangentSpace'));
norm(norm(h-gr))

% Test 5
h1 = SO3VectorFieldHarmonic(g);
h2 = SO3VectorFieldHarmonic(g.right);
norm(norm(h1-h2.left))

%% Test Evaluation routine 

% Test 1
q = quadratureSO3Grid(23,crystalSymmetry,ss);
v = gr.eval(q);
v2 = gr.eval(q(:));
max(norm(vector3d(v)-vector3d(v2)))

%% Test interpolate method
clear

f = SO3Fun.dubna;
cs = f.CS;
ss = specimenSymmetry('222');
f.SS = ss;
g = f.grad;
N = 23;
g.bandwidth = N;

q = quadratureSO3Grid(N,cs);
rot = q.fullGrid;
val = g.eval(rot);
val = right(val);

h = SO3VectorFieldHarmonic.interpolate(rot,val,SO3TangentSpace.leftVector,'regularization',0,'bandwidth',N,'weights',q.weights,cs,ss);
norm(norm(h-g)) / norm(norm(h))







%%
% -------------------------------------------------------------------------
% ----------------------- Test gradient methods ---------------------------
% -------------------------------------------------------------------------

clear
r = rotation.rand;

% SO3FunHarmonic
f = SO3FunHarmonic.example;
norm(f.grad(r) - f.grad(r,'check'))

% SO3FunCBF
f = SO3FunCBF.example;
h = SO3FunHarmonic(f);
norm(f.grad(r) - h.grad(r))

% SO3FunRBF
f = SO3FunRBF.example;
h = SO3FunHarmonic(f);
norm(f.grad(r) - h.grad(r))





%%
% -------------------------------------------------------------------------
% ------------------------ Test SO3VectorFieldRBF -------------------------
% -------------------------------------------------------------------------

clear
f = SO3Fun.dubna;
cs = f.CS;
ss = specimenSymmetry('222');
f.SS = ss;
g1 = SO3VectorFieldRBF(f.grad);
g2 = g1.right;

%% Test approximation

norm(norm(f.grad-g1)) ./ norm(norm(f.grad))

%% Test interpolate method

rot = g1.SO3F.center;
val = g1.eval(rot);
h = SO3VectorFieldRBF.interpolate(rot,val,SO3TangentSpace.leftVector,cs,ss);
norm(norm(h-g1)) / norm(norm(g1))

%% Test evaluation routine

r1 = orientation.rand(crystalSymmetry,ss);
r2 = orientation.rand(cs);

% Test 1
e = r1.symmetrise.inv .* g1.eval(r1.symmetrise);
norm(norm(e-e(1)))

% Test 2
e = r2.symmetrise .* g2.eval(r2.symmetrise);
norm(norm(e-e(1)))

% Test 3
norm(norm( g1.eval(r1) - left(g2.eval(r1)) ))

