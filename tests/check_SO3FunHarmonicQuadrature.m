
clear
rng(0)
F = SO3FunRBF(orientation.rand(50,'Bunge'),SO3DeLaValleePoussinKernel(20));
F = SO3FunHarmonic(F);

S = {'1','211','121','112','222','3','321','312','4','422','6','622','23','432'};
fprintf('\n New iteration \n')
E = NaN(14,14,4);
for s = 1:4
for i = 1:14
for j = 1:14
    switch s
      case 1
        CS = crystalSymmetry(S{i});
        SS = crystalSymmetry(S{j});
      case 2
        CS = crystalSymmetry(S{i});
        SS = specimenSymmetry(S{j});
      case 3
        CS = specimenSymmetry(S{i});
        SS = crystalSymmetry(S{j});
      case 4
        CS = specimenSymmetry(S{i});
        SS = specimenSymmetry(S{j});
    end

    if (CS.id==22 && isa(CS,'specimenSymmetry')) || (SS.id == 22 && isa(SS,'specimenSymmetry'))
      continue;
    end

    f = F; f.CS=CS; f.SS=SS; f=f.symmetrise;
    g = SO3FunHandle(@(rot) f.eval(rot),CS,SS);

    N = 15;
    h1 = SO3FunHarmonic.quadrature(g,'bandwidth',N);
    h2 = SO3FunHarmonic.quadrature(g,'bandwidth',h1.bandwidth+1);

    nodes = regularSO3Grid(CS,SS);
    A = f.eval(nodes);
    B = h1.eval(nodes);
    C = h2.eval(nodes);
    E(i,j,s) = norm(A(:)-B(:)) + norm(A(:)-C(:));
    w = waitbar((j+(i-1)*14+(s-1)*14*14)/(14*14*4));
end
end
end
close(w);

max(E,[],3,'omitnan')



