function check_SO3FunRBFApproximation

%% Approximate SO3FunRBF
SO3F = SO3FunRBF.approximation(SantaFe);
err = calcError(SO3F,SantaFe);

assert(err < 0.02,'SO3FunRBFApproximation:SantaFe',...
    'SO3FunRBFApproximation:SantaFe: FAILED') % ~< 1e-12

%% Approximate SO3FunHarmonic

SO3F1 = SO3FunHarmonic.example;
psi = SO3DeLaValleePoussinKernel(32);
SO3F1 = conv(SO3F1,psi); % smooth odf to be faster
SO3F2 = SO3FunRBF.approximation(SO3F1,'kernel',psi);
err = calcError(SO3F1,SO3F2);

assert(err < 0.02,'SO3FunRBFApproximation:Dubna:Spatial',...
    'SO3FunRBFApproximation:SO3Fun:Dubna: FAILED')

SO3F2 = SO3FunRBF.approximation(SO3F1,'kernel',psi,'harmonic');
err = calcError(SO3F1,SO3F2);

assert(err < 0.02,'SO3FunRBFApproximation:Dubna:Harmonic',...
    'SO3FunRBFApproximation:SO3Fun:Dubna: FAILED') 

%% Approximate SO3G,f(SO3G)

fname = fullfile(mtexDataPath, 'orientation', 'dubna.csv');
[ori, S] = orientation.load(fname,'columnNames',{'phi1','Phi','phi2','values'});

psi = SO3DeLaValleePoussinKernel('halfwidth',5*degree);
SO3F = SO3FunRBF.approximation(ori, S.values,'kernel',psi);
err = norm(SO3F.eval(ori) - S.values) / norm(S.values);

assert(err < 0.02,'SO3FunRBFApproximation:Dubna:SO3G',...
    'SO3FunRBFApproximation:SO3Fun:Dubna: FAILED') 

val = S.values + randn(size(S.values)) * 0.05 * std(S.values);

SO3F = SO3FunRBF.approximation(ori, val,'kernel',psi);
err = norm(SO3F.eval(ori) - S.values) / norm(S.values);

assert(err < 0.05,'SO3FunRBFApproximation:Dubna:SO3G:Noisy',...
    'SO3FunRBFApproximation:SO3Fun:Dubna: FAILED') 

%%

disp('SO3FunRBFApproximation: ok')


end



