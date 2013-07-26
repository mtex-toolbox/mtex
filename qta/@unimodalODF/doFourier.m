function f_hat = doFourier(odf,L,varargin)
% called by ODF/calcFourier

% set parameter
c = odf.c / length(odf.SS) / length(odf.CS);
      
% TODO
% for a few center symmetrize before computing c_hat
if 10*length(odf.center)*length(odf.SS)*length(odf.CS) < max(L^3,100)
  
  g = odf.SS * reshape(quaternion(odf.center),1,[]); % SS x S3G
  g = reshape(g.',[],1);                             % S3G x SS
  g = reshape(g*odf.CS,1,[]);                        % S3G x SS x CS
  % g = quaternion(symmetrise(odf.center));
  
  c = repmat(c,1,length(odf.CS)*length(odf.SS));
else
  g = quaternion(odf.center);
end

% export center in Euler angle
abg = Euler(g,'nfft');
      
% export Chebyshev coefficients
A = getA(odf.psi);
A = A(1:min(max(2,L+1),length(A)));

% calculate Fourier coefficients
f_hat = gcA2fourier(abg,c,A);

% for many center symmetrise f_chat
if 10*length(odf.center)*length(odf.SS)*length(odf.CS) >= L^3
  
  if length(odf.CS) ~= 1
    % symmetrize crystal symmetry
    abg = Euler(odf.CS,'nfft');
    A(1:end) = 1;
    c = ones(1,length(odf.CS));
    f_hat = multiply(f_hat,gcA2fourier(abg,c,A),length(A)-1);
  end
  
  if length(odf.SS) ~= 1
    % symmetrize specimen symmetry
    abg = Euler(odf.SS,'nfft');
    A(1:end) = 1;
    c = ones(1,length(odf.SS));
    f_hat = multiply(gcA2fourier(abg,c,A),f_hat,length(A)-1);
  end
end

end

% --------------------------------------------------------------

function c_hat = gcA2fourier(g,c,A)

% run NFSOFT
f = call_extern('odf2fc','EXTERN',g,c,A);
      
% extract result
c_hat = complex(f(1:2:end),f(2:2:end));

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
