%% Check rotate of SO3Fun's

rng(0)
CS = crystalSymmetry('2');
SS = crystalSymmetry('3');
A = crystalSymmetry('4');


RBF = SO3FunRBF(orientation.rand(200,CS,SS),SO3DeLaValleePoussinKernel('halfwidth',20*degree));


for ind=1:5

switch ind
  case 1
    F = SO3FunHarmonic(RBF); F.isReal = 1;
  case 2
    F = SO3FunBingham.example; F.CS = CS; F.SS = SS;
  case 3 
    F = RBF;
  case 4
    F = SO3FunCBF.example; F.CS = CS; F.SS = SS;
  case 5
    F = SO3FunSBF.example;
end

F2 = SO3FunHandle(@(r) F.eval(r),F.CS,F.SS);

fprintf('\nRight sided rotation:\n')
rot = orientation.rand(A,CS);
a1 = rotate(F,rot,'right');
b1 = rotate(F2,rot,'right');

r = orientation.rand(a1.CS,a1.SS);
e = a1.eval(r.symmetrise(:)) - b1.eval(r.symmetrise(:));
norm(e)
fprintf('Error: %f \n',norm(e))


fprintf('\nLeft sided rotation:\n')
rot = orientation.rand(SS,A);
a2 = rotate(F,rot);
b2 = rotate(F2,rot);

r = orientation.rand(a2.CS,a2.SS);
e = a2.eval(r.symmetrise(:)) - b2.eval(r.symmetrise(:));
fprintf('Error: %f \n',norm(e))

end