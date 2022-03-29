function fhat = symmetrise_fouriercoefficients_aRBWT(fhat,input_flags,CS,SS,sym,varargin)
% Use function properties (realvalued, antipodal, CS, SS) to construct 
% symmetric fourier coefficients

N=dim2deg(length(fhat));

flags=zeros(1,5);
while input_flags>0
  a = floor(log2(input_flags));
  flags(a+1)=1;
  input_flags = input_flags-2^a;
end

for n=1:N

  ind = deg2dim(n)+1:deg2dim(n+1);
  A = reshape(fhat(ind),2*n+1,2*n+1);
  
  if sym(1)+sym(3)~=2
    % There is a 2-fold crystal symmetry Y-axis
    if CS.id==22
      A(n+2:end,:) = (-1).^(n+(1:n)').*flip(A(1:n,:),1);
    elseif CS.multiplicityPerpZ~=1
      A(n+2:end,:) = (-1)^n *flip(A(1:n,:),1);
    end
  
    % There is a 2-fold specimen symmetry Y-axis
    if SS.id==19
      A(:,n+2:end) = (-1).^(n+(1:n)) .* flip(A(:,1:n),2);
    elseif SS.id==22
      A(:,n+2:end) = (1i).^(2*n+(1:n)) .* flip(A(:,1:n),2);
    elseif SS.multiplicityPerpZ~=1
      A(:,n+2:end) = (-1)^n * flip(A(:,1:n),2);
    end
  end
  
  % f is real valued
  if flags(3), A = A + (A==0).*conj(flip(flip(A,1),2)); end
  
  % f is antipodal
  if flags(4), A = A + (A==0).*flip(flip(A,1),2).'; end
  fhat(ind) = A(:);

end

end