function g = grad_right(SO3F,varargin)
% right-sided gradient of an SO3Fun
%
% Syntax
%   G = SO3F.grad % compute the gradient
%   g = SO3F.grad(rot) % evaluate the gradient in rot
%
%   % go 5 degree in direction of the gradient
%   ori_new = exp(rot,5*degree*normalize(g)) 
%
% Input
%  SO3F - @SO3FunHarmonic
%  rot  - @rotation / @orientation
%
% Output
%  G - @SO3VectorFieldHarmonic
%  g - @vector3d
% 

% fallback to generic method
if check_option(varargin,'check')
  g = grad@SO3Fun(SO3F,varargin{:});
  return
end

if nargin>1 && isa(varargin{1},'rotation') && isempty(varargin{1})
  g = vector3d; 
  return
end

% if bandwidth is zero there is nothing to do
if SO3F.bandwidth == 0 
  if nargin>1
    g = vector3d.zeros(size(varargin{1}));
  else
    F = SO3FunHarmonic([0,0,0],crystalSymmetry,SO3F.SS);
    g = SO3VectorFieldHandle(@(r) vector3d(F.subSet(1).eval(r),F.subSet(2).eval(r),F.subSet(3).eval(r)),SO3F.CS,SO3F.SS);
  end
  return; 
end

fhat = ones(deg2dim(SO3F.bandwidth),3);
for n=0:SO3F.bandwidth
  ind = deg2dim(n)+1:deg2dim(n+1);
  FHAT = reshape(SO3F.fhat(ind),2*n+1,2*n+1);
  
  % compute derivative of Wigner-d functions
  k = (-n:n-1)';
  dd = (-1).^(k<0) .* sqrt((n+k+1).*(n-k))/2;

  % derivative around xvector
  X = zeros(2*n+1,2*n+1);
  X(2:end,:) = 1i*dd.*FHAT(1:end-1,:);
  X(1:end-1,:) = X(1:end-1,:) + 1i*dd.*FHAT(2:end,:);

  % derivative around yvector
  Y = zeros(2*n+1,2*n+1);
  Y(2:end,:) = dd.*FHAT(1:end-1,:);
  Y(1:end-1,:) = Y(1:end-1,:) - dd.*FHAT(2:end,:);
  
  % derivative around zvector
  Z = FHAT .* (-n:n)' * (-1i);

  % get Fourier coefficients
  fhat(ind,1) = X(:);
  fhat(ind,2) = Y(:);
  fhat(ind,3) = Z(:);

end

F = SO3FunHarmonic(fhat,crystalSymmetry,SO3F.SS);
% TODO: implement class SO3VectorFieldHarmonicRight
% g = SO3VectorFieldHarmonicRight( F ,SO3F.CS,SO3F.SS );
g = SO3VectorFieldHandle(@(r) vector3d(F.subSet(1).eval(r),F.subSet(2).eval(r),F.subSet(3).eval(r)),SO3F.CS,SO3F.SS);


if nargin > 1 && isa(varargin{1},'rotation')
  ori = varargin{1};
  g = vector3d(g.eval(ori).').';
end
end
