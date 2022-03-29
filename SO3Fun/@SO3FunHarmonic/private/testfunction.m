% Create some SO3Funs

rng('default')

F1=SO3FunHarmonic(rand(20000,1));
F2=SO3FunHarmonic(rand(50000,1));
FC = SO3FunComposition(F1, F2)
mtexdata dubna
odf = pf.calcODF
mtexdata ptx
odf2 = pf.calcODF



cs = crystalSymmetry.load('Ti-Titanium-alpha.cif');
f = fibre.beta(cs);
CBF = fibreODF(f,'halfwidth',10*degree)


cs = crystalSymmetry('1');
kappa = [100 90 80 0];   % shape parameters
U     = eye(4);          % orthogonal matrix
Bing = BinghamODF(kappa,U,cs)

