clear all

rot = orientation.rand(100);
SO3F = calcDensity(rot,'harmonic','bandwidth',25);
SO3F = SO3FunHarmonic(SO3F.components{1}.f_hat)


ori=rotation.rand(10);


%%
tic
    f1=eval2(SO3F,ori);
toc
tic
    f2=eval2v3(SO3F,ori);
toc
tic
    f3=eval2v32(SO3F,ori);
toc

max(abs(f1-f2))
max(abs(f1-f3))
