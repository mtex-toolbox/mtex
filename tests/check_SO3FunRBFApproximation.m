function check_SO3FunRBFApproximation

warning('off','mlsq:itermax')

%% Approximate SO3FunRBF - spatial method - mlsq

for s = [1,1/sqrt(7),-sqrt(21),sqrt(127)]
    SO3F_Ref = s*SantaFe;
    SO3F_Approx = SO3FunRBF.approximate(SO3F_Ref,'mlsq','halfwidth',10*degree);
    err = calcError(SO3F_Ref,SO3F_Approx);

    assert(err < 0.02*abs(s),'SO3FunRBFApproximation:SantaFe',...
        'SO3FunRBFApproximation:SantaFe:Spatial: FAILED') % ~< 1e-12
end

%% Approximate SO3FunRBF - harmonic method

for s = [1,1/sqrt(7),-sqrt(21),sqrt(127)]
    SO3F_Ref = s*SantaFe;
    SO3F_Approx = SO3FunRBF.approximate(SO3F_Ref,'harmonic','halfwidth',7.5*degree);
    err = calcError(SO3F_Ref,SO3F_Approx);

    assert(err < 0.02*abs(s),'SO3FunRBFApproximation:SantaFe',...
        'SO3FunRBFApproximation:SantaFe:Harmonic: FAILED') % ~< 1e-12
end

%% Approximate SO3FunRBF - default method

for s = [1,1/sqrt(7),-sqrt(21),sqrt(127)]
    SO3F_Ref = s*SantaFe;
    SO3F_Approx = SO3FunRBF.approximate(SO3F_Ref,'halfwidth',10*degree); % 'lsqr' will fail
    err = calcError(SO3F_Ref,SO3F_Approx);

    assert(err < 0.02*abs(s),'SO3FunRBFApproximation:SantaFe',...
        'SO3FunRBFApproximation:SantaFe:Spatial: FAILED') % ~< 1e-12
end


%% Approximate SO3FunRBF - mixed +/-I - should use interpolation method

cs = crystalSymmetry('m-3m');
ss = specimenSymmetry();

o1 = orientation.byAxisAngle(vector3d(1,1,1),60*degree,cs,ss);
o2 = orientation.byAxisAngle(vector3d(0,0,1),36.8699*degree,cs,ss);

SO3F_Ref = 2*unimodalODF(o1,cs,ss) - unimodalODF(o2,cs,ss);
% SO3F_Ref.mean == 1

SO3F_Approx = SO3FunRBF.approximate(SO3F_Ref,'halfwidth',7.5*degree);
err = calcError(SO3F_Ref,SO3F_Approx);

assert(err < 0.1,'SO3FunRBFApproximation:MixedIntensities',...
        'SO3FunRBFApproximation:MixedIntensities:Spatial: FAILED') % ~< 1e-12

%% Approximate SO3FunHarmonic

SO3F1 = SO3FunHarmonic.example;
psi = SO3DeLaValleePoussinKernel(32);
SO3F1 = conv(SO3F1,psi); % smooth odf to be faster
SO3F2 = SO3FunRBF.approximate(SO3F1,'kernel',psi);
err = calcError(SO3F1,SO3F2);

assert(err < 0.02,'SO3FunRBFApproximation:Dubna:Spatial',...
    'SO3FunRBFApproximation:SO3Fun:Dubna: FAILED')

SO3F2 = SO3FunRBF.approximate(SO3F1,'kernel',psi,'harmonic');
err = calcError(SO3F1,SO3F2);

assert(err < 0.02,'SO3FunRBFApproximation:Dubna:Harmonic',...
    'SO3FunRBFApproximation:SO3Fun:Dubna: FAILED')

%% Approximate SO3G,f(SO3G)

fname = fullfile(mtexDataPath, 'orientation', 'dubna.csv');
[ori, S] = orientation.load(fname,'columnNames',{'phi1','Phi','phi2','values'});

psi = SO3DeLaValleePoussinKernel('halfwidth',5*degree);
SO3F = SO3FunRBF.approximate(ori, S.values,'kernel',psi,'odf');
err = norm(SO3F.eval(ori) - S.values) / norm(S.values);

assert(err < 0.02,'SO3FunRBFApproximation:Dubna:SO3G',...
    'SO3FunRBFApproximation:SO3Fun:Dubna: FAILED')

val = S.values + randn(size(S.values)) * 0.05 * std(S.values);

SO3F = SO3FunRBF.approximate(ori, val,'kernel',psi,'odf');
err = norm(SO3F.eval(ori) - S.values) / norm(S.values);

assert(err < 0.05,'SO3FunRBFApproximation:Dubna:SO3G:Noisy',...
    'SO3FunRBFApproximation:SO3Fun:Dubna: FAILED')

%%

disp('SO3FunRBFApproximation: ok')

warning('on','mlsq:itermax')


end



