function g = grad(SO3F,varargin)
% gradient of an SO3Fun
%
% Syntax
%   G = SO3F.grad % compute the gradient
%   g = SO3F.grad(rot) % evaluate the gradient in rot
%
%   % go 5 degree in direction of the gradient
%   ori_new = exp(rot,5*degree*normalize(g)) 
%
%   % the right tangent vector
%   g = SO3F.grad(rot,SO3TangentSpace.rightVector)
%
% Input
%  SO3F - @SO3FunHarmonic
%  rot  - @rotation / @orientation
%
% Output
%  G - @SO3VectorFieldHarmonic
%  g - @vector3d
%
% See also
% orientation/exp SO3FunRBF/grad SO3FunCBF/grad SO3VectorFieldHarmonic

% fallback to generic method
if check_option(varargin,'check') 
  g = grad@SO3Fun(SO3F,varargin{:});
  return
end

% eval at list of tensors of length zero -> nothing to do
if nargin>1 && isa(varargin{1},'rotation') && isempty(varargin{1})
  g = SO3TangentVector(vector3d,varargin{:}); 
  return
end

% SO3Fun has bandwidth zero -> nothing to do
if SO3F.bandwidth == 0 
  if nargin>1 && isa(varargin{1},'rotation')
    g = SO3TangentVector(vector3d.zeros(size(varargin{1})),varargin{:});
  else
    g = SO3VectorFieldHarmonic( SO3FunHarmonic([0,0,0],...
      SO3F.CS,specimenSymmetry) , SO3F.CS, SO3F.SS , varargin{:});
  end
  return; 
end

tS = SO3TangentSpace.extract(varargin{:});
% now the actual algorithm

fhat = zeros(deg2dim(SO3F.bandwidth+1),3);

if tS.isLeft

  for n=1:SO3F.bandwidth
    ind = deg2dim(n)+1:deg2dim(n+1);
    FHAT = reshape(SO3F.fhat(ind),2*n+1,2*n+1);
    
    % compute derivative of Wigner-d functions
    l = (-n:n-1);
    dd = (-1).^(l<0) .* sqrt((n+l+1).*(n-l))/2;
    
    % derivative around xvector
    X = zeros(2*n+1,2*n+1);
    X(:,2:end) = 1i*dd.*FHAT(:,1:end-1);
    X(:,1:end-1) = X(:,1:end-1) + 1i*dd.*FHAT(:,2:end);

    % derivative around yvector
    Y = zeros(2*n+1,2*n+1);
    Y(:,2:end) = -dd.*FHAT(:,1:end-1);
    Y(:,1:end-1) = Y(:,1:end-1) + dd.*FHAT(:,2:end);
  
    % derivative around zvector
    Z = FHAT .* (-n:n) * (-1i);

    % get Fourier coefficients
    fhat(ind,1) = X(:);
    fhat(ind,2) = Y(:);
    fhat(ind,3) = Z(:);

  end

  % no more specimen symmetry
  g = SO3VectorFieldHarmonic( SO3FunHarmonic(fhat,SO3F.CS,specimenSymmetry) ,...
    SO3F.CS,SO3F.SS,tS);

else

  for n=1:SO3F.bandwidth

    ind = deg2dim(n)+1:deg2dim(n+1);
    FHAT = reshape(SO3F.fhat(ind),2*n+1,2*n+1);
  
    % compute derivative of Wigner-d functions
    l = (-n:n-1)';
    dd = (-1).^(l<0) .* sqrt((n+l+1).*(n-l))/2;

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

  % no more crystal symmetry
  g = SO3VectorFieldHarmonic( SO3FunHarmonic(fhat,crystalSymmetry,SO3F.SS),...
    SO3F.CS,SO3F.SS ,tS);

end

g.tangentSpace = tS;

if nargin > 1 && isa(varargin{1},'rotation'), g = g.eval(varargin{1}); end

end
