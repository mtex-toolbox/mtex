function val = evalfft(SO3F,ori,varargin)
% evaluate harmonic SO3function in orientations by using FFT
%
% Therefore the rotations are given by euler angles 'ZYZ'. This euler angles
% describe SO(3) as [0,2pi]x[0,pi]x[0,2pi] with some special isues. There is 
% a equidistant grid used for FFT. At least the evaluation at the desired 
% rotations is done by interpolation.
%
% Syntax  
%   evalfft(SO3F,ori)
%   evalfft(SO3F,ori,'GridPointNum',127,'Interpolation','trilinear')
%
% Input
%   SO3F - @SO3FunHarmonic
%   ori  - @rotation
%
% Name-Value Pair Arguments  
%   'GridPointNum'  - H as number of grid points in [0,2*pi) with the points
%                     2*pi*k/H, k=0,...,H-1 and (2*pi)/H as gridconstant
%   'Interpolation' - kind of interpolation respectively to grid points
%                     'round'     = use next grid point
%                     'trilinear' = trilinear interpolation
% Output
%   values of ori at SO3F (double)


N = SO3F.bandwidth;

H=0;
inter='trilinear';
for j=1:2:nargin-2
    if strcmp(varargin{j},'GridPointNum')
        if isnumeric(varargin{j+1}) && mod(varargin{j+1},2)==0 
            if varargin{j+1}>=2*N+2
                H=varargin{j+1}/2-1;
            else
                disp(['The value for GridPointNum is to small. Instead, ', num2str(2*N+2),' is used.'])
                H=N;
            end
        else
            disp('Error. The value for GridPointNum is not a even number.')
            return
        end
    elseif strcmp(varargin{j},'Interpolation')
        inter=varargin{j+1};
        if strcmp(varargin{j+1},'round')
            if H==0, H=255; end
        elseif strcmp(varargin{j+1},'trilinear') 
            if H==0, H=127; end
        else
            disp('Error: Interpolation property not allowed.')
            return
        end
    else
        disp('Error. Property not allowed.')
        return
    end
end
if H==0
    H=max(N,127); % may use 255    
end



% give gridconstant h
h=pi/(H+1);



% 1. calculate FFT of SO3F

% if SO3F is real valued we have (*) and (**) for the Fourier coefficients
% we will use this to speed up computation
if SO3F.isReal

  % create ghat -> k x l x j
  % with  k=-N:N
  %       l= 0:N          -> use ghat(-k,-l,-j)=conj(ghat(k,l,j))        (*)
  %       j=-N:N          -> use ghat(k,l,-j)=(-1)^(k+l)*ghat(k,l,j)     (**)
  ghat=zeros(2*N+1,N+1,2*N+1);

  for n=0:N

    Fhat=reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1); Fhat=Fhat(:,n+1:end);

    d = Wigner_D(n,pi/2); d = d(:,1:n+1);
    D = permute(d,[1,3,2]) .* permute(d(n+1:end,:),[3,1,2]) .* Fhat;
  
    ghat(N+1+(-n:n),1:n+1,N+1+(-n:0)) = ghat(N+1+(-n:n),1:n+1,N+1+(-n:0)) + D;

  end
  % use (**)
  pm = (-1)^(N-1)*reshape((-1).^(1:(2*N+1)*(N+1)),[2*N+1,N+1]);
  ghat(:,:,N+1+(1:N)) = flip(ghat(:,:,N+1+(-N:-1)),3) .* pm;
  
  % needed for (*)
  ghat(:,1,:)=ghat(:,1,:)/2;

else
  ghat=zeros(2*N+1,2*N+1,2*N+1);
  
  for n=0:N

    Fhat=reshape(SO3F.fhat(deg2dim(n)+1:deg2dim(n+1)),2*n+1,2*n+1);

    d = Wigner_D(n,pi/2);
    D = permute(d,[1,3,2]) .* permute(d,[3,1,2]) .* Fhat;

    ghat(N+1+(-n:n),N+1+(-n:n),N+1+(-n:n)) = ghat(N+1+(-n:n),N+1+(-n:n),N+1+(-n:n)) + D;

  end
end

% FFT
f=fftn(ghat,[2*H+2,2*H+2,2*H+2]);

f=f(:,:,1:H+2);                         % because beta is only in [0,pi]
z=(0:2*H+1)'+reshape(0:H+1,1,1,H+2);    % needed to shift summation for FFT from [-N:N] to [0:2N]
f = 2*real(exp(1i*pi*z*N/(H+1)).*f);    % shift summation & use (*)
f=permute(f,[1,3,2]);



% 2) evaluate SO3F in ori

ori=ori(:);
M=length(ori);

% gridconstant h and 2H+2 x H+2 x 2H+2 grid points on [pi/2,5pi/2)x[0,pi]x[-pi/2,3pi/2)

% basic := index of next rounded down grid point of ori 
abg = Euler(ori,'nfft');
% separetely for beta != respectively = 0
null=(abg(:,2)==0);
abg(~null,:) = mod(mod(abg(~null,:)+[-pi/2,0,pi/2],2*pi)/h,2*H+2);
abg(null,:)  = mod(abg(null,:)/h,2*H+2);

% interpolation
if strcmp(inter,'round')

    basic=round(abg);
    ind=basic(:,1)*(2*H+2)*(H+2)+basic(:,2)*(2*H+2)+basic(:,3)+1;
    val=f(ind);

elseif strcmp(inter,'trilinear')

    basic = floor(abg);
    % if beta = pi : we change basic point, to avoid domain error later
    basic((basic(:,2)==H+1),2)=H;

    % get the indices of the other grid points around ori
    X=[0,0,0,0,1,1,1,1;0,0,1,1,0,0,1,1;0,1,0,1,0,1,0,1]';
    gp=reshape(X,1,8,3)+reshape(basic,M,1,3);
    gp(gp==2*H+2)=0;

    % get the indices of this grid points for f(:) from FFT
    ind=gp(:,:,1)*(2*H+2)*(H+2)+gp(:,:,2)*(2*H+2)+gp(:,:,3)+1;

    % transform coordinates in h^3 cube with gp as edges to [0,1]^3
    pkt=abg-basic;
    % calculate therefore a weightmatrix
    w=prod(abs(reshape(X==0,1,8,3)-reshape(pkt,M,1,3)),3);

    % get evaluation in ori
    val=sum(w.*f(ind),2);
end

end