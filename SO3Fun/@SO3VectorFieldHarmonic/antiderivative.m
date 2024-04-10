function f = antiderivative(SO3VF,varargin)
% antiderivative of an vector field
%
% Syntax
%   F = SO3VF.antiderivative % compute the antiderivative
%   f = SO3VF.antiderivative(rot) % evaluate the antiderivative in rot
%
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%  rot  - @rotation / @orientation
%
% Output
%  F - @SO3FunHarmonic
%  f - @double
% 
% See also
% SO3FunHarmonic/grad  SO3VectorFieldHarmonic/curl SO3VectorFieldHarmonic

% if bandwidth is zero there is nothing to do
if SO3VF.bandwidth == 0 
  if nargin>1 && isa(varargin{1},'rotation')
    f = zeros(size(varargin{1}));
  else
    f = SO3FunHarmonic(0, SO3VF.CS,SO3VF.SS);
  end
  return; 
end

% check whether the vector field is conservative
if ~check_option(varargin,'conservative')
  c = SO3VF.curl;
  n = sqrt(sum(norm(c.SO3F).^2));
  if n>1e-3
    error(['The vector field is not conservative (not the gradient of some SO3Fun),' ...
           ' since the curl = ',n,' is not vanishing.'])
  end
end

% compute antiderivative
fhat = zeros(deg2dim(SO3VF.bandwidth+1),1);
for n=1:SO3VF.bandwidth
  ind = deg2dim(n)+1:deg2dim(n+1);
  Z = SO3VF.SO3F.fhat(ind,3);
  Y = SO3VF.SO3F.fhat(ind,2);
  Y = reshape(Y,2*n+1,2*n+1);
  
  l = (-n:n-1);
  dd = (-1).^(l<0) .* sqrt((n+l+1).*(n-l))/2;

  if SO3VF.internTangentSpace.isRight
    dd = dd.';
    FHAT = reshape(Z,2*n+1,2*n+1) * 1i ./(-n:n).';
    if n==1
      FHAT(n+1,:) = Y(n+1+1,:)./dd(n+1,:);
    else
      FHAT(n+1,:) = (Y(n+1+1,:)+dd(n+2,:).*FHAT(n+3,:))./dd(n+1,:);
    end
  else
    FHAT = reshape(Z,2*n+1,2*n+1) * 1i ./(-n:n);
    if n==1
      FHAT(:,n+1) = -Y(:,n+1+1)./dd(:,n+1);
    else
      FHAT(:,n+1) = (-Y(:,n+1+1)+dd(:,n+2).*FHAT(:,n+3))./dd(:,n+1);
    end
  end
  
  fhat(ind) = FHAT(:);
end

f = SO3FunHarmonic( fhat , SO3VF.CS,SO3VF.SS);

if nargin > 1 && isa(varargin{1},'rotation')
  ori = varargin{1};
  f = f.eval(ori);
end

end
