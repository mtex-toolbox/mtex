function [Mf,hhat,ghat] = calcpdf_special3(odf,LMax,M,theta,varargin)
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
%N = LMax;
%M = 2*LMax+1;

N = length(theta);

mminus = -(M-1):(M-1);
rho   = 2*pi*mminus./(2*M);
[rho,theta] = meshgrid(rho,theta);
r = [reshape(rho,1,[]);reshape(theta,1,[])];


%% precomputation for nfsft
% precomputation
nfsft_precompute(2*LMax,1000);
plan = nfsft_init_advanced(2*LMax,size(r,2),NFSFT_NORMALIZED);

nfsft_set_x(plan,r);
% node-dependent precomputation
nfsft_precompute_x(plan);


%% step 0 - compute Fourier coefficients of the ODF -> fhat

odf = calcFourier(odf,LMax);
odf_hat = Fourier(odf,'bandwidth',LMax,'l2-normalization');
  
%% step 1 - compute hhat(L,k,k')
hhat = zeros(LMax+1,2*LMax+1,2*LMax+1);
for L = 0:LMax
  for l = LMax:-1:L
    
    CG = sphericalClebschGordan(l,2*L) * sqrt(2*l+1) ./ sqrt(4*L+1);
    fhat = reshape(odf_hat(deg2dim(l)+1:deg2dim(l+1)),2*l+1,2*l+1);
    
    ll = 1 + LMax + (-l:l);
    hhat(1+L,ll,ll) = hhat(1+L,ll,ll) + reshape(fhat .* CG,[1,2*l+1,2*l+1]);
                
  end
end
 
hhat= conj(hhat);

%% step 2 rotate

ghat = zeros(4*LMax+1,(2*LMax+1)^2);
for L = 0:LMax
  
  [k,kk] = ndgrid(-LMax:LMax);
    
  ind = abs(k + kk) <= 2*L;
  k = k(ind); kk = kk(ind);
    
  kminus = k - kk + 1 + 2*LMax;
  kplus = k + kk + 2*L;
  %kplus = 4*L - kplus;
  
  ghat(kminus + (4*LMax+1)*(kplus + (2*L)^2)) = hhat(L+1,LMax+1+k + (2*LMax+1) *(LMax+kk));
end


%% step 3 - compute ghat by taking the Fourier transform along the fist dimension
% 


% set up Fouriermatrix
kminus = -2*LMax:2*LMax;
mplus = 0:2*M-2;
F = bsxfun(@(a,b) exp(2 * pi * 1i *a.*b./(2*M)),kminus,mplus.');

ghat2 = F * ghat .* sqrt(4*pi);

%% step 4 - compute Mf by spherical Fourier transforms along the second dimension

% allocate output
gtilde = zeros([N,2*M-1,2*M-1]);

for mplus = 0:2*M-2
  
  % Set Fourier coefficients.
  nfsft_set_f_hat_linear(plan,ghat2(mplus+1,:).');

  % transform
  nfsft_trafo(plan);
  
  % store results
  out = nfsft_get_f(plan);
  gtilde(:,1+mplus,:) = reshape(out,[N 1 2*M-1]);
  
end

% clear memory
nfsft_finalize(plan);

%% step 5 rotate back

[m,mm] = ndgrid(0:M-1,0:M-1);

mplus = m+mm;
mminus= M+m-mm-1;

% fill the inner rhombus
Mf(:,:) = gtilde(:,1+mplus + (mminus)*(2*M-1));

% reshape
Mf = reshape(Mf,[N,M,M]);


function d = deg2dim(l)
% dimension of the harmonic space up to order l

d = l*(2*l-1)*(2*l+1)/3;
