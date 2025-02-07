function fhat = symmetriseWignerCoefficients(fhat,input_flags,CS,SS,sym,varargin)
% Use function properties (realvalued, antipodal, CS, SS) to construct 
% symmetric SO(3)-Fourier/Wigner coefficients after using the method 
% wignerTrafoAdjointmex with flag 2^4 (use symmetries)

% get bandwidth
N=dim2deg(length(fhat));

% extract flags
flags=zeros(1,5);
while input_flags>0
  a = floor(log2(input_flags));
  flags(a+1)=1;
  input_flags = input_flags-2^a;
end

% symmetrise for n=1
if N>=1
  CShat = CS.WignerD('order',1);
  fhat(2:10) = reshape(CShat,3,3) * reshape(fhat(2:10),3,3) ./ sqrt(3);
  SShat = SS.WignerD('order',1);
  fhat(2:10) = reshape(fhat(2:10),3,3) * reshape(SShat,3,3) ./ sqrt(3);
end

% symmetrise Wigner coefficients
for n=2:N

  ind = deg2dim(n)+1:deg2dim(n+1);
  A = reshape(fhat(ind),2*n+1,2*n+1);
  
  if sym(1)+sym(3)~=2
    % There is a 2-fold crystal symmetry Y-axis
    if ismember(CS.id,3:5) || ...
        (ismember(CS.id,19:21) && isa(CS,'specimenSymmetry')) || ...
        (ismember(CS.id,22:24) && isa(CS,'crystalSymmetry'))
      A(n+2:end,:) = (-1).^(n+(1:n)').*flip(A(1:n,:),1);
    elseif CS.multiplicityPerpZ~=1
      A(n+2:end,:) = (-1)^n *flip(A(1:n,:),1);
    end
  
    % There is a 2-fold specimen symmetry Y-axis
    if ismember(SS.id,3:5) ||...
        (ismember(SS.id,19:21) && isa(SS,'specimenSymmetry')) || ...
        (ismember(SS.id,22:24) && isa(SS,'crystalSymmetry'))      
      A(:,n+2:end) = (-1).^(n+(1:n)) .* flip(A(:,1:n),2);
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