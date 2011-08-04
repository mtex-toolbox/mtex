function Mf = calcpdf_special(odf,M,N,varargin)
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


%% step 0 - compute Fourier coefficients of the ODF -> fhat

LMax = 4;
odf = calcFourier(odf,LMax);

  
%% step 1 - compute hhat(L,k,k')
for L = 0:LMax
  hhat{L+1} = zeros(2*LMax+1,2*LMax+1);
  for l = LMax:-1:L
    
    fhat = fliplr(Fourier(odf,'order',l));
    CG = fliplr(sphericalClebschGordan(l,2*L));
    ind = LMax + 1 + (-l:l);
    hhat{L+1}(ind,ind) = hhat{L+1}(ind,ind) + fhat ./sqrt(2*l+1) .* CG;
    
  end
end


%% step 2 - compute ghat({mplus},L,kplus)


ghat_index = @(l,k) (l+1).^2 -l + k;

for mplus = 0:2*M-2
  
  ghat{mplus+1} = zeros(ghat_index(2*LMax,2*LMax),1);
  for L = 0:LMax
    for kplus = -2*L:2*L
      
      % sum over kminus
      kminus = -2*L + abs(kplus) :2: 2*L - abs(kplus);                  
      
      ghat{mplus+1}(ghat_index(2*L,kplus)) = ...
        sum(hhat{L+1}(sub2ind([2*LMax+1,2*LMax+1],...
        1+LMax+(kplus-kminus)./2,...
        1+LMax+(kplus+kminus)./2)) .* ...
        exp(1i * pi * mplus .* kminus ./ M)); %#ok<*AGROW>
      
    end
  end
end


%% step 3 - compute Mf by spherical Fourier transforms

% allocate output
Mf = zeros(N,M,M);

for mplus = 0:2*M-2
  
  mm = min(mplus,2*M-2-mplus);
  mminus = -mm:2:mm;
  
  theta = fft_theta(linspace(0,pi,N));
  rho   = fft_rho(mminus*pi./M);
  [theta,rho] = meshgrid(theta,rho);
  r = [reshape(rho,1,[]);reshape(theta,1,[])];

  P_hat = [real(ghat{mplus+1}(:)),-imag(ghat{mplus+1}(:))].';

  out = call_extern('pdf2pf','EXTERN',r,P_hat);
  
  Mf(:,...
    sub2ind([M,M],1+(mplus+mminus)./2,1+(mplus-mminus)./2)) = out;
  
end

