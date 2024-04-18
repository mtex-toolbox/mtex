function SO3F = symmetrise(SO3F,varargin)
% Symmetrise the harmonic coefficients of an SO3FunHarmonic w.r.t. its symmetries.
% 
% Therefore we compute the harmonic coefficients of the SO3FunHarmonic 
% by using symmetry properties.
%
% Syntax
%   SO3F = symmetrise(SO3F)
%
% Input
%  SO3F - @SO3FunHarmonic
%
% Output
%  SO3F - @SO3FunHarmonic
%

if SO3F.bandwidth==0 || check_option(varargin,'skipSymmetrise')
  return
end

s = size(SO3F);
SO3F = reshape(SO3F,prod(s));

L = SO3F.bandwidth;

cs = get_option(varargin,'CS',SO3F.CS);
ss = get_option(varargin,'SS',SO3F.SS);
 
if numSym(cs) ~= 1 % symmetrize crystal symmetry
  SO3F.fhat = convSO3(SO3F.fhat,cs.WignerD(L));
end
  
if numSym(ss) ~= 1 % symmetrize specimen symmetry
  SO3F.fhat = convSO3(ss.WignerD(L),SO3F.fhat);
end

% grain exchange symmetry

if check_option(varargin,'antipodal')
  ensureCompatibleSymmetries(SO3F,'antipodal')
  for l = 0:SO3F.bandwidth
    ind = deg2dim(l)+1:deg2dim(l+1);
    ind2 = reshape(flip(ind),2*l+1,2*l+1)';
    SO3F.fhat(ind,:) = 0.5*(SO3F.fhat(ind,:) + SO3F.fhat(ind2(:),:));
  end
end
  
SO3F = reshape(SO3F,s);

end


% % ------------------------ Test ------------------------------
function test

E = zeros(45,3);
E(:,1) = 1:45;
S = {'1','-1','211','m11','2/m11','121','1m1','12/m1','112','11m','112/m',...
     '222','2mm','m2m','mm2','mmm',...
     '3','-3','321','3m1','-3m1','312','31m','-31m',...
     '4','-4','4/m','422','4mm','-42m','-4m2','4/mmm',...
     '6','-6','6/m','622','6mm','-62m','-6m2','6/mmm',...
     '23','m-3','432','-43m','m-3m'};
N = 12;

for k=1:45
  
  rng(0)
  CS = crystalSymmetry(S{k});
  SS = specimenSymmetry(S{k});
  fhat = rand(deg2dim(N+1),1)+rand(deg2dim(N+1),1)*1i-0.5-0.5i;
  F = SO3FunHarmonic(fhat,CS,CS); F.antipodal = 1;
  G = SO3FunHarmonic(fhat,SS,SS); G.antipodal = 1;
  H = SO3FunHarmonic(fhat,CS,SS); H.antipodal = 1;
  J = SO3FunHarmonic(fhat,SS,CS); J.antipodal = 1;

  E(k,2) = max(abs(G.fhat-F.fhat));
  E(k,3) = max(abs(H.fhat-F.fhat));
  E(k,4) = max(abs(J.fhat-F.fhat));

  r = rotation.rand(500);
  E(k,5) = max(abs(F.eval(r)-F.eval(inv(r))));
  E(k,6) = max(abs(G.eval(r)-G.eval(inv(r))));
  E(k,7) = max(abs(H.eval(r)-H.eval(inv(r))));
  E(k,8) = max(abs(J.eval(r)-J.eval(inv(r))));

end

E  % for k=19:24 we have: CS.rot is different to SS.rot

end








