function val = evalfft(SO3F,varargin)
% evaluate harmonic SO3function in rotations by using fft
%
% Therefore the rotations are given by euler angles 'ZYZ'. This euler
% angles describe SO(3) as [0,2pi]x[0,pi]x[0,2pi] with some special isues.
% There is a equidistant grid used for fft. At least the evaluation at the
% desired rotations is done by interpolation between the grid points.
%
% dft with interpolation
%
% Syntax
%   val = evalfft(SO3F,rot,'trilinear','GridPointNum',127)
%
% Input
%   SO3F - @SO3FunHarmonic
%   rot  - @rotation
%
% Output
%   val - approximation of SO3F at rotations
%
% Options
%   'GridPointNum' - H as number of grid points in [0,2*pi):
%                           grid points 2*pi*k/H, k=0,...,H-1 and
%                           gridconstant (2*pi)/H
%   'nearest'      - use function value of nearest grid point
%   'trilinear'    - trilinear interpolation by the neighbor points
%
% 
% Do fft for the fourier coefficients of SO3F and give the grid if there
% are no evaluation points given.
%
% Syntax
%   val = evalfft(SO3F)
%
% Input
%   SO3F - @SO3FunHarmonic
%
% Output
%   val - structure array composed of a grid and the SO3F values at this
%   grid points
%

% if there are no @rotation given, do dft
if ~isempty(varargin) && isa(varargin{1},'rotation')
  rot = varargin{1};
  dft = false;
else
  dft = true;
end

N = SO3F.bandwidth;

% get number of grid points
H = ceil(get_option(varargin,'GridPointNum',2*N+1)/2-1);

% get interpolation method
method = get_flag(varargin,{'nearest','trilinear'},'trilinear');

% give gridconstant h
h = pi/(H+1);


% 1) calculate FFT of SO3F

% if SO3F is real valued we have (*) and (**) for the Fourier coefficients
% we will use this to speed up computation
if SO3F.isReal

  % create ghat -> k x l x j
  % with  k = -N:N
  %       l =  0:N      -> use ghat(-k,-l,-j)=conj(ghat(k,l,j))        (*)
  %       j = -N:N      -> use ghat(k,l,-j)=(-1)^(k+l)*ghat(k,l,j)     (**)
  ghat = zeros(2*N+1,N+1,2*N+1);

  for n = 0:N

    Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);
    Fhat = Fhat(:,n+1:end);

    d = Wigner_D(n,pi/2); d = d(:,1:n+1);
    D = permute(d,[1,3,2]) .* permute(d(n+1:end,:),[3,1,2]) .* Fhat;

    ghat(N+1+(-n:n),1:n+1,N+1+(-n:0)) =ghat(N+1+(-n:n),1:n+1,N+1+(-n:0))+D;

  end
  % use (**)
  pm = (-1)^(N-1)*reshape((-1).^(1:(2*N+1)*(N+1)),[2*N+1,N+1]);
  ghat(:,:,N+1+(1:N)) = flip(ghat(:,:,N+1+(-N:-1)),3) .* pm;

  % needed for (*)
  ghat(:,1,:) = ghat(:,1,:)/2;

  % correct ghat by exp(-2*pi*i*(-1/4*l+1/4*k))
  z = zeros(2*N+1,N+1,2*N+1)+(-N:N)'-(0:N);
  ghat = ghat.*exp(-0.5*pi*1i*z);

else

  ghat = zeros(2*N+1,2*N+1,2*N+1);

  for n = 0:N

    Fhat = reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);

    d = Wigner_D(n,pi/2);  d = d(:,1:n+1);
    D = permute(d,[1,3,2]) .* permute(d,[3,1,2]) .* Fhat;

    ghat(N+1+(-n:n),N+1+(-n:n),N+1+(-n:0)) = ...
        ghat(N+1+(-n:n),N+1+(-n:n),N+1+(-n:0)) + D;

  end

  % use (**)
  pm = -reshape((-1).^(1:(2*N+1)*(2*N+1)),[2*N+1,2*N+1]);
  ghat(:,:,N+1+(1:N)) = flip(ghat(:,:,N+1+(-N:-1)),3) .* pm;

  % correct ghat by exp(-2*pi*i*(-1/4*l+1/4*k))
  z = zeros(2*N+1,2*N+1,2*N+1)+(-N:N)'-(-N:N);
  ghat = ghat.*exp(-0.5*pi*1i*z);

end


% fft
f = fftn(ghat,[2*H+2,2*H+2,2*H+2]);

f = f(:,:,1:H+2);                          % because beta is only in [0,pi]

if SO3F.isReal
  % need to shift summation of fft from [-N:N] to [0:2N]
  z = (0:2*H+1)'+reshape(0:H+1,1,1,H+2);
  f = 2*real(exp(1i*pi*N/(H+1)*z).*f);     % shift summation & use (*)
else
  % need to shift summation of fft from [-N:N] to [0:2N]
  z = (0:2*H+1)+(0:2*H+1)'+reshape(0:H+1,1,1,H+2);
  f = exp(1i*pi*N/(H+1)*z).*f;
end

f = permute(f,[1,3,2]);

if dft
  grid(:,[3,2,1]) = combvec(0:2*N+1,0:2*N+1,0:2*N+1)'*pi/(N+1);
  grid = grid(grid(:,2)<=pi,:);
  grid = rotation.byEuler(grid,'nfft');
  val.grid = reshape(grid,size(f));
  val.value = f;
  return
end



% 2) evaluate SO3F in rot

sz = size(rot);
rot = rot(:);
M = length(rot);

% gridconst h and 2H+2 x H+2 x 2H+2 grid points in [0,2pi)x[0,pi]x[0,2pi)
abg = Euler(rot,'nfft');
abg = mod(abg/h,2*H+2);

% interpolation
if strcmpi(method,'nearest')

  % basic := index of nearest grid point of rot
  basic = round(abg);
  ind = basic(:,1)*(2*H+2)*(H+2)+basic(:,2)*(2*H+2)+basic(:,3)+1;
  val = f(ind);

elseif strcmpi(method,'trilinear')
  
  % basic := index of next rounded down grid point of rot
  basic = floor(abg);
  % if beta = pi : we change basic point, to avoid domain error later
  basic((basic(:,2)==H+1),2) = H;

  % get the indices of the other grid points around rot
  X = [0,0,0,0,1,1,1,1;0,0,1,1,0,0,1,1;0,1,0,1,0,1,0,1]';
  gp = reshape(X,1,8,3)+reshape(basic,M,1,3);
  gp(gp==2*H+2) = 0;

  % get the indices of this grid points for f(:) from FFT
  ind = gp(:,:,1)*(2*H+2)*(H+2)+gp(:,:,2)*(2*H+2)+gp(:,:,3)+1;

  % transform coordinates in h^3 cube with gp as edges to [0,1]^3
  pkt = abg-basic;
  % calculate therefore a weightmatrix
  w = prod(abs(reshape(X==0,1,8,3)-reshape(pkt,M,1,3)),3);

  % get evaluation in rot
  val = sum(w.*f(ind),2);

end

val = reshape(val,sz);

end