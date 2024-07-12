function [f,nodes] = evalSectionsEquispacedFFT(SO3F,oS,varargin)
% Evaluate an @SO3FunHarmonic on @ODFSections by using an equispaced grid 
% along the other 2 Euler angles
%     $$(\alpha_a,\beta_b,\gamma_c) = (\frac{2\pi a}{H_1},\frac{\pi b}{H_2-1},\gamma_c)$$
% where $a=0,...,H_1-1$, $b=0,...,H_2-1$ and $c=0,...,S_{num}$.
%
% Therefore we transform the SO(3) Fourier series to an usual Fourier series
% equivalent as in the function <SO3FunHarmonic.eval.html |eval|>.
% But we use an 2-variate equispaced FFT instead of the NFFT in second step.
%
% Syntax
%   f = evalSectionsEquispacedFFT(SO3F,oS)
%   [f,nodes] = evalSectionsEquispacedFFT(SO3F,oS,'resolution',2.5*degree)
%
% Input
%  SO3F - @SO3FunHarmonic
%  oS - @ODFSection (gamma)
%
% Options
%  'resolution' - shape constant along Euler angles. (default = 2.5°)
%
% Output
%  nodes - @orientation
%  f - values at this grid points
%
% See also
% SO3FunHarmonic/eval SO3FunHarmonic/evalNFSOFT SO3FunHarmonic/evalEquispacedFFT

% TODO: Use symmetries to speed up 
% TODO: Do the same for alpha,phi1,phi2 sections by shifting them to gamma
%       sections

% Adjust bandwidth
N = SO3F.bandwidth;
[~,~,gMax] = fundamentalRegionEuler(SO3F.SRight,SO3F.SLeft,'ABG');
LCM = lcm((1+double(round(2*pi/gMax/SO3F.SRight.multiplicityZ) == 4))*SO3F.SRight.multiplicityZ,SO3F.SLeft.multiplicityZ);
while mod(2*N+2,LCM)~=0
  N = N+1;
end
SO3F.bandwidth = N;


% Compute Fourier coefficients
% flags: 2^0 -> use L_2-normalized Wigner-D functions
%        2^2 -> fhat are the fourier coefficients of a real valued function
%        2^4 -> use right and left symmetry
flags = 2^0+2^2+2^4;
ghat = wignerTrafo(SO3F,flags,'bandwidth',N);
ghat = permute(ghat,[3,2,1]);


% make sure the grid is equispaced
res = get_option(varargin,'resolution',2.5*degree);
if isscalar(res), res = [1,1]*res; end
[a_max,b_max,~] = fundamentalRegionEuler(SO3F.CS,SO3F.SS,'ABG');
s = ceil([a_max,b_max]./res);
res = [a_max,b_max]./s;
H = 2*pi./res;
if any(s<=1)
  error('The resolution is to big.')
end

% Assume 'gamma' sections
gamma = oS.gamma;

% Do 2-variate fft for all Euler angles gamma
f = zeros([s+1,length(gamma)]);
for g = 1:length(gamma)

  exponentials = exp( -1i*gamma(g) * reshape(-N:N,1,1,[]) );
  A = sum(ghat.*exponentials,3);

  % For small H we go through a smaller FFT(H) several times
  % Hence we reduce the size of the fourier coefficient matrix ghat by adding 
  % the coefficients with same complex exponentials.
  sz = size(A);
  if any(H<sz)
    dim = ceil(sz./H);
    B = zeros(dim.*H);
    B(1:size(A,1),1:size(A,2)) = A;
    B = reshape(B,H(1),dim(1),H(2),dim(2));
    % Note that H(1) and H(2) should be bigger than 1 to avoid errors by squeezing
    A = squeeze(sum(B,[2,4]));
  end

  % fft
  f2 = fft2(A,H(1),H(2));
  
  % cut beta to [0,pi]
  if s(1) == H(1)
    f2 = f2([1:s(1),1],1:s(2)+1);
  else
    f2 = f2(1:s(1)+1,1:s(2)+1);
  end
  
  % shift the summation of fft from [-|_N/r_|:|_N/r_|]x[-N:N]x[-|_N/s_|:|_N/s_|] to 
  % [0:2*|_N/r_|]x[0:2N]x[0:2*|_N/s_|]. With r- & s-fold rotational symmetry
  % around Z-axis and |_ ... _| denotes the round off operator.
  f(:,:,g) = 2*real(exp(2i*pi*N*(0:s(2))/H(2)) .* f2);

end

f = permute(f,[2,1,3]);

% compute the corresponding nodes
if nargout>1
  grid = combvec((0:s(1))*res(1),(0:s(2))*res(2),gamma);
  grid = orientation.byEuler(grid,'nfft',SO3F.CS,SO3F.SS);
  nodes = reshape(grid,[s+1,length(gamma)]);
  nodes = permute(nodes,[2,1,3]);
end




end



function v = combvec(v1,v2,v3)
% This function does the same as the combvec() function from Digital 
% Processing Toolbox and additionaly transpose the output matrix.
% It is a simple version for the special case of three input vectors.
  l1 = length(v1);
  l2 = length(v2);
  l3 = length(v3);

  V1 = repmat(v1.',l2*l3,1);
  V2 = repmat(v2,l1,l3);
  V3 = repmat(v3,l1*l2,1);

  v = [V1,V2(:),V3(:)];
end