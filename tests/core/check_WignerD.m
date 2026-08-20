function check_WignerD
% check WignerD conformity with NSOFT/SO3FunHarmonic
%
% WignerD(ori,'kernel',psi) is the harmonic expansion of the radial basis
% function psi centered in ori, so it has to agree with
% calcFourier(SO3FunRBF(ori,psi,1)) up to the L2 normalization applied in
% calc_err below. This is the only coverage of WignerD against the harmonic
% transform.
%
% Was a known failure (#2582) until WignerD learned to read its 'kernel'
% argument at all: it used to ignore the weights, so the two differed by
% exactly psi.A, and it expanded to maxSO3Bandwidth instead of the kernel's
% own - 366145 coefficients against 10660, which is the length mismatch that
% threw first.
%
% The '+1' below makes no difference, since calcFourier truncates at the
% kernel's own bandwidth whatever it is asked for.

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