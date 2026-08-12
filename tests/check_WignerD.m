function check_WignerD
% check WignerD conformity with NSOFT/SO3FunHarmonic
%
% KNOWN FAILURE, see https://github.com/mtex-toolbox/mtex/issues/2582
%
% This test asserts that WignerD(ori,'kernel',psi) and
% calcFourier(SO3FunRBF(ori,psi,1)) agree up to the L2 normalization. They
% do not: they differ by exactly the kernel coefficients psi.A, i.e.
% calcFourier applies the kernel weights and WignerD does not, although psi
% was handed to it. The two also disagree on the returned bandwidth - 366145
% coefficients (degree 64) against 10660 (degree 19) - and it is that length
% mismatch which throws first, as "Arrays have incompatible sizes".
%
% Kept, in slow/, rather than deleted: the identity it checks is the right
% one and this is the only coverage of WignerD against the harmonic
% transform. It goes back to core/ once #2582 is resolved. The '+1' below is
% part of the same knot - it makes no difference any more, since calcFourier
% truncates at the kernel's own bandwidth whatever it is asked for.

check_unimodal('-1','-1',50)
check_unimodal('-3m','-1',70)
check_unimodal('m-3m','mmm',90)

check_multimodal('6/mmm',5)
check_multimodal('m-3',15)

disp('WignerD: ok')

end

function err = calc_err(SO3F,C)

% apply l2-normalization and conjugate
% see also L2normalizeFourierCoefficients
L = dim2deg(length(C));
for n=1:L
    ind = deg2dim(n)+1:deg2dim(n+1);
    C(ind,:) = conj(C(ind,:)) / sqrt(2*n+1);
end

% reference coefficents
Cx = calcFourier(SO3F,'bandwidth',dim2deg(numel(C))+1); % +1 looks like a bug in mtex
err = sum(conj(Cx-C).*(Cx-C));

end

function check_unimodal(c,s,p)

cs = crystalSymmetry(c);
ss = specimenSymmetry(s);
psi = SO3DeLaValleePoussinKernel(p);

qr = rotation.byEuler(354.263*degree, 131.733*degree, 38.2379*degree,'ZXZ');
ori = orientation(qr,cs,ss);

C = WignerD(ori,'kernel',psi);
odf = SO3FunRBF(ori,psi,1);

assert(abs(calc_err(odf,C)) < 1e-10,'WignerD:',...
    'WignerD:unimodal: FAILED') % ~< 1e-12

end

function check_multimodal(c,bandwidth)

cs = crystalSymmetry(c);
ss = specimenSymmetry('-1');
psi = SO3DirichletKernel(bandwidth);

n = 100;
ori = orientation.rand(n,cs,ss);

C = WignerD(ori,'kernel',psi);
odf = SO3FunRBF(ori,psi,ones(numel(ori),1)./length(ori));

Cm = mean(C,2);
assert(abs(calc_err(odf,Cm)) < 1e-10,'WignerD:',...
    'WignerD:multimodal: FAILED') % ~< 1e-12

end