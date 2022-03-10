function fhat = symmetrise_fouriercoefficients_aRBWT(fhat,input_flags,sym,varargin)
% 
% sym = [1,0,0,1];
% sym(1) --> 2-fold crystal symmetry Y-axis
% sym(3) --> 2-fold specimen symmetry Y-axis
% flags(3) --> f is real valued
% flags(4) --> f is antipodal  
%

N=dim2deg(length(fhat));

flags=0;
while input_flags>0
  a = floor(log2(input_flags));
  flags(a+1)=1;
  input_flags = input_flags-2^a;
end

for n=1:N

  ind = deg2dim(n)+1:deg2dim(n+1);
  A = reshape(fhat(ind),2*n+1,2*n+1);
  if sym(1)~=1, A(n+2:end,:) = (-1)^n *flip(A(1:n,:),1); end
  if sym(3)~=1, A(:,n+2:end) = (-1)^n * flip(A(:,1:n),2); end
  if flags(3), A = A + (A==0).*conj(flip(flip(A,1),2)); end
  if flags(4), A = A + (A==0).*flip(flip(A,1),2).'; end
  fhat(ind) = A(:);

end

end