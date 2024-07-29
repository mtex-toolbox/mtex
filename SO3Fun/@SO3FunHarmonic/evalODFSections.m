function Z = evalODFSections(SO3F,oS,varargin)
% Plotting @SO3FunHarmonics on Sections needs evaluation. We can evaluate
% (also for high bandwidths) fast on equispaced grids by fft.
%
% Therefore we transform the SO(3) Fourier series to an usual Fourier series
% equivalent as in the function <SO3FunHarmonic.eval.html |eval|>.
% But we use an 2-variate equispaced FFT instead of the NFFT in second step.
%
% In case of phi1Sections, phi2Sections, alphaSections and gammaSections 
% one Euler angle is fixed by the section. The other 2 Euler angles reads
% as equispaced grids. 
% The grid of the gammaSections for instance reads as
% $$(\alpha_a,\beta_b,\gamma_c) = (\frac{2\pi a}{H_1},\frac{\pi b}{H_2-1},\gamma_c)$$
% where $a=0,...,H_1-1$, $b=0,...,H_2-1$ and $c=0,...,S_{num}$.
% 
% In case of the sigma sections the grid reads as
% $$(\alpha_a,\beta_b,\gamma_c) = (\frac{2\pi a}{H_1},\frac{\pi b}{H_2-1},\sigma_c+\pi/6-\frac{2\pi a}{H_1})$$
% where $a=0,...,H_1-1$, $b=0,...,H_2-1$ and $c=0,...,S_{num}$.
% Here we transform to an ordinary Fourier series and evaluate with FFT
% along 2nd Euler angle. Moreover we use an rank-1 lattice based FFT 
% along 1st and 3rd Euler angle, which means we apply the FFT diagonal over 
% the Index set.
%
% Syntax
%   f = evalODFSections(SO3F,oS,'resolution',2.5*degree)
%
% Input
%  SO3F - @SO3FunHarmonic
%  oS - @ODFSection
%
% Options
%  'resolution' - shape constant along Euler angles. (default = 2.5°)
%
% Output
%  f - values at this grid points
%
% See also
% SO3FunHarmonic/eval SO3FunHarmonic/evalNFSOFT SO3FunHarmonic/evalEquispacedFFT


% plotSection@SO3Fun(SO3F.subSet(1),varargin{:});
S3G = oS.makeGrid('resolution',2.5*degree,varargin{:});
SO3F.isReal = 1;

if ~isa(oS,'phi2Sections') && ~isa(oS,'phi1Sections') && ...
    ~isa(oS,'gammaSections') && ~isa(oS,'alphaSections') && ...
    ~isa(oS,'sigmaSections')
  varargin{end+1}='check';
end

% fallback to generic method
if check_option(varargin,'check')
  Z = SO3F.eval(S3G,varargin{:});
  return
end


% Go to ordinary Fourier series
% flags: 2^0 -> use L_2-normalized Wigner-D functions
%        2^2 -> fhat are the fourier coefficients of a real valued function
%        2^4 -> use right and left symmetry
N = SO3F.bandwidth;
flags = 2^0+2^2+2^4;
ghat = wignerTrafo(SO3F,flags,'bandwidth',N);

% 2*real( sum ghat(k,j,l) .* exp(-1i*(k*g+j*b+l*a)) )
% 2*real(sum(ghat .* exp(-1i*((-10:10)'*g+(-10:10)*b+reshape(0:10,1,1,[])*a)),'all'))

% precompute grid size for fft
theta = oS.plotGrid.theta(:,1);
rho = oS.plotGrid.rho(1,:);
[rhoMin,rhoMax] = rhoRange(oS.sR);
[thetaMin,thetaMax] = thetaRange(oS.sR,rho(1));
H = [round(2*pi/abs(thetaMax-thetaMin))*(length(theta)-1),round(2*pi/abs(rhoMax-rhoMin))*(length(rho)-1)];

% sigmaSections are equispaced w.r.t. an rank-1 lattice in alpha and gamma.
% Hence we compute them seperatly.
if isa(oS,'sigmaSections')
  
  if H(1)~=H(2)
    Z = evalODFSections(SO3F,oS,varargin{:},'check');
  end
  
  % transform ghat to k x l x j
  ghat = permute(ghat,[1,3,2]);

  % evaluate section wise
  sec = oS.omega;
  for ind = 1:length(sec)
    
    shift = (S3G(2,1,1).gamma-pi/6);
    % shift Fourier series by section angle and pi/6
    hhat = ghat .* exp(-1i*(-N:N)'*(shift+pi/6+sec(ind)) -1i*(0:N)*shift);
    
    % transform rank-1 lattice based bivariate Fourier series 
    % (along alpha x gamma) into univariate Fourier series of length H(1)
    [l,k] = meshgrid(0:N,-N:N);
    indSet = mod(l-k,H(1));
    ahat = zeros(H(1),2*N+1);
    for m=1:H(1)
      index = find(indSet==m-1) + (0:2*N)*(2*N+1)*(N+1);
      ahat(m,:) = sum(hhat(index),1);
    end
    
    % Do fft
    v = fft2(ahat.',H(1),H(2));
    v(:,end+1) = v(:,1);
    v(end+1,:) = v(1,:);
    v = v(1:length(theta),1:length(rho));

    % shift indice j (beta) from -N:N to 0:2N
    v = v.*exp(1i*theta*N);
    
    % since real valued function we have half number of Fourier coefficients
    % and symmetry property
    Z(:,:,ind) = 2*real(v);

  end

  return
end

% computation for equidistant ODFSections

% permute ghat such that:
%     - theta is 1st dimension
%     - rho is 2nd dimension
%     - sec is 3rd dimension
% and transform to Bunge if necessary
if isa(oS,'phi2Sections')
  sec = oS.phi2;
  % transform to Bunge
  ghat = ghat .* 1i.^(-(-N:N)'+reshape(0:N,1,1,[]));
  % permute to Phi x phi1 x phi2
  ghat = permute(ghat,[2,3,1]);
elseif isa(oS,'phi1Sections')
  sec = oS.phi1;
  % transform to Bunge
  ghat = ghat .* 1i.^(-(-N:N)'+reshape(0:N,1,1,[]));
  % permute to Phi x phi2 x phi1
  ghat = permute(ghat,[2,1,3]);
elseif isa(oS,'gammaSections')
  sec = oS.gamma;
  % permute to beta x alpha x gamma
  ghat = permute(ghat,[2,3,1]);
elseif isa(oS,'alphaSections')
  sec = oS.alpha;
  % permute to beta x gamma x alpha
  ghat = permute(ghat,[2,1,3]);
end

% evaluate section wise
for ind=1:length(sec)

  % evaluate w.r.t. section angle (3rd dimension)
  if size(ghat,3)==2*N+1
    l = -N:N;
  else
    l = 0:N;
  end
  Ghat = sum(ghat.*exp(-1i*reshape(l,1,1,[])*sec(ind)),3);
  
  % Do bivariate FFT on 1st and 2nd dimension
  v = fft2(Ghat,H(1),H(2));
  v(:,end+1) = v(:,1);
  v(end+1,:) = v(1,:);
  v = v(1:length(theta),1:length(rho));

  % shift indices from -N:N to 0:2N
  if size(Ghat,1)==2*N+1
    v = v.*exp(1i*theta*N);
  end
  if size(Ghat,2)==2*N+1
    v = v.*exp(1i*rho*N);
  end

  % since real valued function we have half number of Fourier coefficients
  % and symmetry property
  Z(:,:,ind) = 2*real(v);

end

end