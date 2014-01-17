function Mf = calcpdf_special(odf,LMax,varargin)
% compute the pdf for h = (theta,rhoh), r = (theta,rhor)
%
%% Input
%  odf   - @ODF
%  theta -
%  rhoh,rhor -
%
%% Output
%  Mf - M f(theta,rhoh,rhor)
%

%% output nodes
N = LMax;
M = 2*LMax+1;

mminus = -4*LMax:4*LMax;
theta = linspace(0,pi,N);
rho   = mminus*pi./M;
[rho,theta] = meshgrid(rho,theta);
r = [reshape(rho,1,[]);reshape(theta,1,[])];


%% precomputation for nfsft
% precomputation
nfsft_precompute(2*LMax,1000);
plan = nfsft_init_advanced(2*LMax,size(r,2),0);

nfsft_set_x(plan,r);
% node-dependent precomputation
nfsft_precompute_x(plan);


%% step 0 - compute Fourier coefficients of the ODF -> fhat

odf = calcFourier(odf,LMax);
odf_hat = Fourier(odf,'bandwidth',LMax);
  
%% step 1 - compute hhat(L,k,k')
hhat = zeros(4*LMax+1,(2*LMax+1)^2);
for L = 0:LMax
  for l = LMax:-1:L
    CG = fliplr(sphericalClebschGordan(l,2*L));
    fhat = fliplr(reshape(odf_hat(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1));
    
    [k,kk] = meshgrid(-l:l);
    
    ind = abs(k + kk) <= 2*L;
    k = k(ind); kk = kk(ind);
    
    kminus = k - kk + 1 + 2*LMax;
    kplus = k + kk + 2*L;

    hhat(kminus + (4*LMax+1)*(kplus + (2*L)^2)) = ...
      hhat(kminus + (4*LMax+1)*(kplus + (2*L)^2)) + ...
      fhat(k+l+1 + (2*l+1).* (l + kk)) .* CG(k+l+1 + (2*l+1).* (l + kk));
            
  end
end
    
%% step 2 - compute ghat by taking the Fourier transform along the fist dimension
% 

% set up Fouriermatrix
kminus = -2*LMax:2*LMax;
mplus = 0:2*M-2;
F = bsxfun(@(a,b) exp(1i * pi*a.*b./M),kminus,mplus.');

ghat = F * hhat;


%% step 3 - compute Mf by spherical Fourier transforms along the second dimension

% allocate output
Mf = zeros([N,M,M]);

for mplus = 0:2*M-2
  
  mm = min(mplus,2*M-2-mplus);
  mminus = -mm:2:mm;

  % Set Fourier coefficients.
  nfsft_set_f_hat_linear(plan,ghat(mplus+1,:).');

  % transform
  nfsft_trafo(plan);
  
  % store results
  % function values
  out = real(nfsft_get_f(plan));
  out = reshape(out,N,[]);
  Mf(:,...
    sub2ind([M,M],1+(mplus+mminus)./2,1+(mplus-mminus)./2)) = out(:,4*LMax+1+mminus);
  
end


% clear memory
nfsft_finalize(plan);



function d = deg2dim(l)
% dimension of the harmonic space up to order l

d = l*(2*l-1)*(2*l+1)/3;
