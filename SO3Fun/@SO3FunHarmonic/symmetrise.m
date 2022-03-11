function SO3F = symmetrise(SO3F,varargin)
% compute harmonic coefficients of SO3Fun by using symmetry properties
%
% Syntax
%  f_hat = symmetrise(SO3F)
%
% Input
%  SO3F - @SO3FunHarmonic
%
% Output
%  f_hat - harmonic/Fouier/Wigner-D coefficients
%

s = size(SO3F);
SO3F = reshape(SO3F,prod(s));

L = SO3F.bandwidth;

cs = SO3F.CS.properGroup;
ss = SO3F.SS.properGroup;
 
if numSym(cs) ~= 1
  % symmetrize crystal symmetry
  c = ones(1,numSym(cs))/numSym(cs);
  SO3F.fhat = multiply(gcA2fourier(cs.rot,c,ones(L+1,1)),SO3F.fhat,L);
end
  
if numSym(ss) ~= 1
  % symmetrize specimen symmetry
  c = ones(1,numSym(ss))/numSym(ss);
  SO3F.fhat = multiply(SO3F.fhat,gcA2fourier(ss.rot,c,ones(L+1,1)),L);
end

% grain exchange symmetry
if SO3F.antipodal || check_option(varargin,'antipodal')
  for l = 0:L
    ind = deg2dim(l)+1:deg2dim(l+1);
    ind2 = reshape(flip(ind),2*l+1,2*l+1)';
    % if CS and SS are '321', by symmetry properties it follows, that all 
    % fourier coefficients with odd row or column indices have to be 0
    if cs.id==19  
      ind3 = ind(iseven(-l:l).*iseven(-l:l)'==0);
      SO3F.fhat(ind3(:),:)=0;
    end
    % if CS and SS are '312' it follows by symmetry properties, that all 
    % fourier coefficients which row or column indices are not multiple of
    % 4 have to be 0
    if cs.id==22
      ind3 = ind((mod(-l:l,4)==0).*(mod(-l:l,4)==0).'==0);
      SO3F.fhat(ind3(:),:)=0;
    end
    SO3F.fhat(ind,:) = 0.5*(SO3F.fhat(ind,:) + SO3F.fhat(ind2(:),:));
  end
end
  
SO3F = reshape(SO3F,s);

end

% --------------------------------------------------------------

function c_hat = gcA2fourier(g,c,A)

% 2^4 -> nfsoft-represent
% 2^2 -> nfsoft-use-DPT
nfsoft_flags = bitor(2^4,4);
plan = nfsoftmex('init',length(A)-1,length(g),nfsoft_flags,0,4,1000,2*ceil(1.5*(length(A)+1)));
nfsoftmex('set_x',plan,Euler(g,'nfft').');
nfsoftmex('set_f',plan,c(:));
nfsoftmex('precompute',plan);
nfsoftmex('adjoint',plan);
c_hat = nfsoftmex('get_f_hat',plan);
nfsoftmex('finalize',plan);

for l = 1:length(A)-1
  ind = (deg2dim(l)+1):deg2dim(l+1);
  c_hat(ind) = A(l+1)* reshape(c_hat(ind),2*l+1,2*l+1);
end
  
end

% --------------------------------------------------------------

% multiply Fourier matrices
function f = multiply(f1,f2,lA)
s1 = size(f1,2);
s2 = size(f2,2);
f = zeros(length(f1),max(s1,s2));
for l = 0:lA
  ind = deg2dim(l)+1:deg2dim(l+1);
  f(ind,:) = reshape(pagemtimes( reshape(f1(ind,:),2*l+1,2*l+1,s1) , ...
    reshape(f2(ind,:),2*l+1,2*l+1,s2) ),length(ind),max(s1,s2));
end

end
