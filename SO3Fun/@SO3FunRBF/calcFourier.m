function f_hat = calcFourier(SO3F,varargin)
% compute harmonic coefficients of SO3Fun
%
% Syntax
%
%  f_hat = calcFourier(SO3F)
%
%  f_hat = calcFourier(SO3F,'bandwidth',L)
%
% Input
%  SO3F - @SO3FunRBF
%     L - maximum harmonic degree / bandwidth
%
% Output
%  f_hat - harmonic/Fouier/Wigner-D coefficients
%

L = get_option(varargin,'bandwidth',SO3F.bandwidth);

cs = SO3F.CS.properGroup;
ss = SO3F.SS.properGroup;

% the weights
c = SO3F.weights / numSym(cs) / numSym(ss);

% the center orientations
g = SO3F.center;

% for a few center symmetrize before computing c_hat
symCenter = 10*length(SO3F.center) * numSym(cs) * numSym(ss) < max(L^3,100);
if symCenter
  
  g = symmetrise(SO3F.center,'proper');
  c = repmat(c(:).',size(g,1),1);
  
end
 
% export Chebyshev coefficients
A = SO3F.psi.A;
A = A(1:min(max(2,L+1),length(A)));

% calculate Fourier coefficients
f_hat = gcA2fourier(g,c,A);

% for many center symmetrise f_chat
if ~symCenter
  
  if numSym(cs) ~= 1
    % symmetrize crystal symmetry
    A(1:end) = 1;
    c = ones(1,numSym(cs));
    f_hat = multiply(gcA2fourier(cs.rot,c,A),f_hat,length(A)-1);
  end
  
  if numSym(ss) ~= 1
    % symmetrize specimen symmetry
    A(1:end) = 1;
    c = ones(1,numSym(ss));
    f_hat = multiply(f_hat,gcA2fourier(ss.rot,c,A),length(A)-1);
  end
  
  % grain exchange symmetry
  if SO3F.antipodal
    for l = 0:length(A)-1
      ind = deg2dim(l)+1:deg2dim(l+1);
      f_hat(ind) = 0.5* (reshape(f_hat(ind),2*l+1,2*l+1) + ...
        reshape(f_hat(ind),2*l+1,2*l+1)');
    end    
  end
  
end

% add constant portion
f_hat(1) = f_hat(1) + SO3F.c0;

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

% multiply Fourier matrixes
function f = multiply(f1,f2,lA)

f = zeros(numel(f1),1);
for l = 0:lA  
  ind = deg2dim(l)+1:deg2dim(l+1);  
  f(ind) = reshape(f1(ind),2*l+1,2*l+1) * ...
    reshape(f2(ind),2*l+1,2*l+1);
end

end
