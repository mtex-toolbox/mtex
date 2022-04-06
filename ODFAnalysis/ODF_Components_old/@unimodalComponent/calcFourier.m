function f_hat = calcFourier(component,L,varargin)
% called by ODF/calcFourier

qss = quaternion(component.SS);
qcs = quaternion(component.CS);

% set parameter
c = component.weights / length(qss) / length(qcs);
  
% TODO
% for a few center symmetrize before computing c_hat
if 10*length(component.center)*length(qss)*length(qcs) < max(L^3,100)
  
  g = qss * reshape(quaternion(component.center),1,[]); % SS x S3G
  g = reshape(g.',[],1);                             % S3G x SS
  g = reshape(g * qcs,1,[]);                        % S3G x SS x CS
  % g = quaternion(symmetrise(odf.center));
  
  c = repmat(c,1,length(qcs)*length(qss));
else
  g = quaternion(component.center);
end
 
% export Chebyshev coefficients
A = component.psi.A;
A = A(1:min(max(2,L+1),length(A)));

% calculate Fourier coefficients
f_hat = gcA2fourier(g,c,A);

% for many center symmetrise f_chat
if 10*length(component.center)*length(qss)*length(qcs) >= L^3
  
  if length(qcs)>1  % symmetrize crystal symmetry
    A(1:end) = 1;
    c = ones(1,length(qcs));
    f_hat = multiply(gcA2fourier(qcs,c,A),f_hat,length(A)-1);
  end
  
  if length(qss)>1  % symmetrize specimen symmetry
    A(1:end) = 1;
    c = ones(1,length(qss));
    f_hat = multiply(f_hat,gcA2fourier(qss,c,A),length(A)-1);
  end
  
  if component.antipodal
    for l = 0:length(A)-1
      ind = deg2dim(l)+1:deg2dim(l+1);
      f_hat(ind) = 0.5* (reshape(f_hat(ind),2*l+1,2*l+1) + ...
        reshape(f_hat(ind),2*l+1,2*l+1)');
    end    
  end
  
end

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
