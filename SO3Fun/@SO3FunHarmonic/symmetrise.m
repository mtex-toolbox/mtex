function [SO3F,psi] = symmetrise(SO3F,varargin)
% Symmetrise the harmonic coefficients of an SO3FunHarmonic w.r.t. its 
% symmetries or a center orientation.
% 
% Therefore we compute the harmonic coefficients of the SO3FunHarmonic 
% by using symmetry properties.
%
% Syntax
%   SO3Fs = symmetrise(SO3F)
%   SO3Fs = symmetrise(SO3F,'CS',cs,'SS',ss)
%   [SO3Fs,psi] = symmetrise(SO3F,ori)
%
% Input
%  SO3F - @SO3FunHarmonic
%  cs,ss - @crystalSymmetry, @specimenSymmetry
%  ori - @orientation (center)
%
%
% Output
%  SO3Fs - @SO3FunHarmonic
%  psi - @SO3Kernel
%

if SO3F.bandwidth==0 || check_option(varargin,'skipSymmetrise')
  return
end

s = size(SO3F);
SO3F = reshape(SO3F,prod(s));

L = SO3F.bandwidth;

% symmetrise with respect to an axis
if nargin>1 && isa(varargin{1},'rotation')
  
  % Forget about the symmetries
  SO3F.CS = crystalSymmetry;
  SO3F.SS = specimenSymmetry;
  center = rotation(varargin{1});

  % rotate SO3F such that center -> rotation.id
  if center ~= rotation.id
    SO3F = rotate(SO3F,inv(center));
  end

  % start with a zero function
  fhat = SO3F.fhat;
  SO3F.fhat = 0; SO3F.bandwidth = L;
  
  % set all Fourier coefficients f_hat(n,k,l) = 0 for k ~= l and compute the
  % mean in each Fourier matrix
  A = zeros(L+1,prod(s));
  for n = 0:L
    ind = deg2dim(n)+1:2*n+2:deg2dim(n+1);
    A(n+1,:) = mean(fhat(ind,:));
    SO3F.fhat(ind,:) = A(n+1,:);
  end
  if prod(s)==1
    psi = SO3Kernel(real(A) .* sqrt(2*(0:L)'+1));
  else
    for i=1:prod(s)
      psi{i} = SO3Kernel(real(A(:,i)) .* sqrt(2*(0:L)'+1));
    end
  end

  % rotate SO3F back
  if center ~= rotation.id
    SO3F = rotate(SO3F,center);
  end

  return
end


cs = get_option(varargin,'CS',SO3F.CS);
ss = get_option(varargin,'SS',SO3F.SS);
 
if numSym(cs) ~= 1 % symmetrize crystal symmetry
  SO3F.fhat = convSO3(SO3F.fhat,cs.WignerD('bandwidth',L));
end
  
if numSym(ss) ~= 1 % symmetrize specimen symmetry
  SO3F.fhat = convSO3(ss.WignerD('bandwidth',L),SO3F.fhat);
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








