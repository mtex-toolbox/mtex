function SO3VF = transformInternTangentSpace(SO3VF,varargin)
% Change the tangent space representation of an harmonic SO3VectorField
% between left and right. Therefore the bandwidth changes by {+1,0,-1}.
% We can compute it directly on the harmonic coefficients, since this
% change of the tangent space basis reads as linear combinations and 
% products with Wigner_D functions of degree 1.
%

% obtain underlying SO3FunHarmonic
f = SO3VF.SO3F;

% transform left tangent space to right
if SO3VF.internTangentSpace.isLeft
  x = ( sqrt(2)*Prod_D1(f(3),-1,0) + sqrt(2)*Prod_D1(f(3),1,0) + ...
    Prod_D1(f(1)-1i*f(2),-1,-1) + Prod_D1(f(1)-1i*f(2),1,-1) + ...
    Prod_D1(f(1)+1i*f(2),-1,1) + Prod_D1(f(1)+1i*f(2),1,1) )/sqrt(12);
  y = ( sqrt(2)*Prod_D1(1i*f(3),-1,0) + sqrt(2)*Prod_D1(-1i*f(3),1,0) + ...
    Prod_D1(1i*f(1)+f(2),-1,-1) + Prod_D1(-1i*f(1)-f(2),1,-1) + ...
    Prod_D1(1i*f(1)-f(2),-1,1) + Prod_D1(-1i*f(1)+f(2),1,1) )/sqrt(12);
  z = ( sqrt(2)*Prod_D1(f(3),0,0) + Prod_D1(f(1)+1i*f(2),0,1) + Prod_D1(f(1)-1i*f(2),0,-1) )/sqrt(6);
  SO3VF = SO3VectorFieldHarmonic([x;y;z],SO3VF.hiddenCS,SO3VF.hiddenSS,-abs(SO3VF.tangentSpace));
  return
end

% transform right tangent space to left
if SO3VF.internTangentSpace.isRight
  x = ( sqrt(2)*Prod_D1(f(3),0,-1) + sqrt(2)*Prod_D1(f(3),0,1) + ...
    Prod_D1(f(1)+1i*f(2),-1,-1) + Prod_D1(f(1)-1i*f(2),1,-1) + ...
    Prod_D1(f(1)+1i*f(2),-1,1) + Prod_D1(f(1)-1i*f(2),1,1) )/sqrt(12);
  y = ( sqrt(2)*Prod_D1(-1i*f(3),0,-1) + sqrt(2)*Prod_D1(1i*f(3),0,1) + ...
    Prod_D1(-1i*f(1)+f(2),-1,-1) + Prod_D1(-1i*f(1)-f(2),1,-1) + ...
    Prod_D1(1i*f(1)-f(2),-1,1) + Prod_D1(1i*f(1)+f(2),1,1) )/sqrt(12);
  z = ( sqrt(2)*Prod_D1(f(3),0,0) + Prod_D1(f(1)-1i*f(2),1,0) + Prod_D1(f(1)+1i*f(2),-1,0) )/sqrt(6);
  SO3VF = SO3VectorFieldHarmonic([x;y;z],SO3VF.hiddenCS,SO3VF.hiddenSS,abs(SO3VF.tangentSpace));
end



end





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%%                          Additional Functions       
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function f_new = Prod_D1(f,r,s)
% Compute the product of an SO3FunHarmonic with the Wigner-D function of
% degree 1 and orders r,s on frequency domain, i.e.
% SO3F(R) * D_1^{r,s}(R).
%
% Syntax
%   SO3F = Prod_D1(f,r,s)
%
% Input
%  f - @SO3FunHarmonic
%  r,s - {-1,0,1} 
%
% Output
%  SO3F - @SO3FunHarmonic
%
% Example (Test)
%   N = 20
%   f = SO3FunHarmonic(rand(deg2dim(N+1),1));
%   for r=-1:1
%     for s=-1:1
%       fhat = zeros(3);
%       fhat(2+r,2+s)=1;
%       g = f .* SO3FunHarmonic([0;fhat(:)]);
%       f_new = Prod_D1(f,r,s);
%       norm(g-f_new)
%     end
%   end
%
%

% bandwidth
N = f.bandwidth;

% construct fhat vector of f_new
fhat = zeros(deg2dim(N+2),1);

% elaborate bandwidth 0 separately
fhat(6+r+3*s) = f.fhat(1)/sqrt(3);

for n=1:N

  % harmonic coefficients of f of actual bandwidth
  coeff = f.fhat(deg2dim(n)+1:deg2dim(n+1));
  coeff = reshape(coeff,2*n+1,2*n+1);

  % update fhat of f_new at bandwidth n-1
  a = CGC(n,r,-1) .* CGC(n,s,-1)' .* sqrt((2*n+1)/(2*n-1));
  v = coeff .* a;
  v = v(2-r:end-1-r,2-s:end-1-s);
  ind = deg2dim(n-1)+1:deg2dim(n);
  fhat(ind) = fhat(ind) + v(:);

  % update fhat at bandwidth n
  b = CGC(n,r,0) .* CGC(n,s,0)';
  v = zeros(2*n+3);
  v(2:end-1,2:end-1) = coeff .* b;
  v = v(2-r:end-1-r,2-s:end-1-s);
  ind = deg2dim(n)+1:deg2dim(n+1);
  fhat(ind) = fhat(ind) + v(:);

  % update fhat at bandwidth n+1
  c = CGC(n,r,1) .* CGC(n,s,1)' .* sqrt((2*n+1)/(2*n+3)) ;
  ind = reshape(deg2dim(n+1)+1:deg2dim(n+2),2*n+3,2*n+3);
  ind = ind(2+r:end-1+r,2+s:end-1+s);
  fhat(ind) = fhat(ind) + coeff .* c;

end

% output - the product with a degree 1 Wigner-D function is no longer
% symmetric under f's groups, but it still lives in f's frames
f_new = SO3FunHarmonic(sqrt(3)*fhat, stripSym(f.SRight), stripSym(f.SLeft));

end


function A = CGC(n,r,m)
% compute Clebsch-Gordan-Coefficient vectors explicitly
% for k=-n,...,n which describe the coefficients of
% D_n^{k,l} * D_1^{r,s}.
% That means:
% < n , k ; 1 , r | n+m , k+r > where r=-1,0,1 and m= -1,0,1
%

k = (-n:n)';
% TODO: stabalize a,b,c

% Compute <n,k;1,0|n+m,k> for k=-n,...,n
if r==0
  switch m
    case -1
      A = -sqrt(n.^2-k.^2)/sqrt(n*(2*n+1));
    case 0
      A = k/sqrt(n*(n+1));
    case 1
      A = sqrt((n+1).^2-k.^2)/sqrt((n+1)*(2*n+1));
  end
end

% Compute <n,k;1,1|n+m,k+1> for k=-n,...,n
if r==1
  switch m
    case -1
      A = sqrt((n-k).*(n-k-1))/sqrt(2*n*(2*n+1));
    case 0
      A = -sqrt((n-k).*(n+k+1))/sqrt(2*n*(n+1));
    case 1
      A = sqrt((n+k+1).*(n+k+2))/sqrt(2*(n+1)*(2*n+1));
  end
  A = (-1).^(k<0) .* A;
end

% Compute <n,k;1,-1|n+m,k-1> for k=-n,...,n
if r==-1
  switch m
    case -1
      A = sqrt((n+k).*(n+k-1))/sqrt(2*n*(2*n+1));
    case 0
      A = sqrt((n+k).*(n-k+1))/sqrt(2*n*(n+1));
    case 1
      A = sqrt((n-k+1).*(n-k+2))/sqrt(2*(n+1)*(2*n+1));
  end
  A = (-1).^(k>0) .* A;
end

end