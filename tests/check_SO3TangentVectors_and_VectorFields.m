%%
clear

% construct Vector Fields
f = SO3Fun.dubna;
cs = f.CS;
ss = specimenSymmetry('222');
f.SS = ss;
g1 = f.grad
g2 = g1.right
h1 = g1.right('internTangentSpace');
h2 = h1.left

% % Test left and right and constructor

% orientations
r1 = orientation.rand(cs);
r2 = orientation.rand(crystalSymmetry,ss);

% test
g1.eval(r1.symmetrise) - h2.eval(r1.symmetrise)
g2.eval(r2.symmetrise) - h1.eval(r2.symmetrise)

% % Test curl and antiderivative

% curl
norm(g1.curl)
norm(g2.curl)
norm(h1.curl)
norm(h2.curl)

% antiderivative
norm(g1.antiderivative+1-SO3FunHarmonic(f))
norm(g2.antiderivative+1-SO3FunHarmonic(f))
norm(h1.antiderivative+1-SO3FunHarmonic(f))
norm(h2.antiderivative+1-SO3FunHarmonic(f))

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

%%

g = g.right;

% Test 4
h = SO3VectorFieldHarmonic.quadrature(g);
h = right(left(h,'internTangentSpace'));
norm(norm(h-g))

% Test 5
q = quadratureSO3Grid(23,crystalSymmetry,ss);
v = g.eval(q);
v2 = g.eval(q(:));
max(norm(vector3d(v)-vector3d(v2)))
