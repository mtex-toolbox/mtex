function d = div(SO3VF,varargin)
% left-sided divergence of an SO3VectorFieldHarmonic
%
% Syntax
%   D = SO3VF.div % compute the divergence
%   d = SO3VF.div(rot) % evaluate the divergence in rot
%
% Input
%  SO3VF - @SO3VectorFieldHarmonic
%  rot  - @rotation / @orientation
%
% Output
%  D - @SO3FunHarmonic
%  d - @double divergence of |SO3VF| at rotation |rot|
%
% See also
% SO3VectorField/div SO3FunHarmonic/grad


% fallback to generic method
if check_option(varargin,'check') 
  d = div@SO3VectorField(SO3VF,varargin{:});
  return
end

% Use right sided routine
if SO3VF.internTangentSpace.isRight
  d = div_right(SO3VF,varargin{:});
  return
end

if nargin>1 && isa(varargin{1},'rotation') && isempty(varargin{1})
  d = [];
  return
end

% if bandwidth is zero there is nothing to do
if SO3VF.bandwidth == 0 
  if nargin>1
    d = zeros(size(varargin{1}));
  else
    d = SO3FunHarmonic(0,SO3VF.CS,SO3VF.SS);
  end
  return; 
end

fhat = ones(deg2dim(SO3VF.bandwidth),1);
for n=0:SO3VF.bandwidth
  ind = deg2dim(n)+1:deg2dim(n+1);
  FHAT1 = reshape(SO3VF.SO3F(1).fhat(ind),2*n+1,2*n+1);
  FHAT2 = reshape(SO3VF.SO3F(2).fhat(ind),2*n+1,2*n+1);
  FHAT3 = reshape(SO3VF.SO3F(3).fhat(ind),2*n+1,2*n+1);

  % compute derivative of Wigner-d functions
  l = (-n:n-1);
  dd = (-1).^(l<0) .* sqrt((n+l+1).*(n-l))/2;

  % derivative around xvector
  X = zeros(2*n+1,2*n+1);
  X(:,2:end) = 1i*dd.*FHAT1(:,1:end-1);
  X(:,1:end-1) = X(:,1:end-1) + 1i*dd.*FHAT1(:,2:end);

  % derivative around yvector
  Y = zeros(2*n+1,2*n+1);
  Y(:,2:end) = -dd.*FHAT2(:,1:end-1);
  Y(:,1:end-1) = Y(:,1:end-1) + dd.*FHAT2(:,2:end);
  
  % derivative around zvector
  Z = FHAT3 .* (-n:n) * (-1i);

  % get Fourier coefficients
  fhat(ind,1) = X(:) + Y(:) + Z(:);

end

d = SO3FunHarmonic( fhat ,SO3VF.CS,SO3VF.SS);

if nargin > 1 && isa(varargin{1},'rotation')
  ori = varargin{1};
  d = d.eval(ori);
end

end