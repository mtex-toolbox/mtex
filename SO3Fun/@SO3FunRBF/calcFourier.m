function f_hat = calcFourier(SO3F,L,varargin)
% called by ODF/calcFourier

if nargin == 1, L = SO3F.bandwidth; end

% the weights
c = SO3F.weights / length(SO3F.SS) / length(SO3F.CS);

% the center orientations
g = SO3F.center;

% for a few center symmetrize before computing c_hat
symCenter = 10*length(SO3F.center)*length(SO3F.SS)*length(SO3F.CS) < max(L^3,100);
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
  
  if length(SO3F.CS) ~= 1
    % symmetrize crystal symmetry
    A(1:end) = 1;
    c = ones(1,length(SO3F.CS));
    f_hat = multiply(gcA2fourier(SO3F.CS,c,A),f_hat,length(A)-1);
  end
  
  if length(SO3F.SS) ~= 1
    % symmetrize specimen symmetry
    A(1:end) = 1;
    c = ones(1,length(SO3F.SS));
    f_hat = multiply(f_hat,gcA2fourier(SO3F.SS,c,A),length(A)-1);
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
