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
% TODO: If H is small we go through a smaller FFT(H) several times. 
%       Hence we could reduce the size of the fourier coefficient matrix 
%       ghat by adding the coefficients which corresponds to the same 
%       complex exponentials.


% Adjust bandwidth
N = SO3F.bandwidth;
[~,~,gMax] = fundamentalRegionEuler(SO3F.SRight,SO3F.SLeft,'ABG');
LCM = lcm((1+double(round(2*pi/gMax/SO3F.SRight.multiplicityZ) == 4))*SO3F.SRight.multiplicityZ,SO3F.SLeft.multiplicityZ);
while mod(2*N+2,LCM)~=0
  N = N+1;
end
SO3F.bandwidth = N;


% compute ghat -> k x j x l
% with  k = -N:N
%       j = -N:N    -> use ghat(k,-j,l) = (-1)^(k+l) * ghat(k,-j,l)   (*)
%       l =  0:N    -> use ghat(-k,-j,-l) = conj(ghat(k,j,l))        (**)
% flags: 2^0 -> use L_2-normalized Wigner-D functions
%        2^2 -> fhat are the fourier coefficients of a real valued function
%        2^4 -> use right and left symmetry
flags = 2^0+2^2+2^4;
sym = [min(SO3F.SRight.multiplicityPerpZ,2),SO3F.SRight.multiplicityZ,...
  min(SO3F.SLeft.multiplicityPerpZ,2),SO3F.SLeft.multiplicityZ];
ghat = representationbased_coefficient_transform(N,SO3F.fhat,flags,sym);
ghat = symmetriseFourierCoefficients(ghat,flags,SO3F.SRight,SO3F.SLeft,sym);
ghat = permute(ghat,[3,2,1]);
% correct ghat by i^(-k+l)
z = - (0:N)'+ reshape(-N:N,1,1,[]);
ghat = ghat.*(1i).^z;


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
  nodes = permute(reshape(grid,[s+1,length(gamma)]),[2,1,3]);
end




end

% function OldFunction(SO3F,varargin)
% 
% N = SO3F.bandwidth;
% 
% if isa(varargin{1},'ODFSections'), oS = varargin{1}; else, oS =[]; end
% [a_max,b_max,g_max] = fundamentalRegionEuler(SO3F.CS,SO3F.SS,varargin{:});
% if isempty(oS)
%   gamma = mod((0:5)*g_max/6+pi/2,2*pi);
%   shift = 1;
% elseif isa(oS,'gammaSections')
%   gamma = oS.gamma;
%   shift = 0; 
% elseif isa(oS,'phi2Sections')
%   gamma = mod(oS.phi2+pi/2,2*pi);
%   shift = 1;
% elseif isa(oS,'phi1Sections')
%   % phi1-sections are analogous to alpha sections. We transform SO3F(R(a,b,g))
%   % to SO3F(R(g,b,a)).
%   fhat = SO3F.fhat;
%   for n=0:N
%     ind = deg2dim(n)+1 : deg2dim(n+1);
%     fhat(ind) = (-1).^((1:2*n+1)+(1:2*n+1).') .* reshape(fhat(ind),2*n+1,2*n+1).';
%   end
%   a_max = g_max;
%   SO3F = SO3FunHarmonic(fhat,SO3F.SS,SO3F.CS);
%   gamma = mod(oS.phi1-pi/2,2*pi);
%   shift = -1;
% end
% 
% 
% 
% % get grid size along 1st and 2nd Euler angles
% res = get_option(varargin,'resolution',2.5*degree);
% if length(res)==1
%   res = [1,1]*res;
% end
% s = ceil([a_max,b_max]./res);
% res = [a_max,b_max]./s;
% H = 2*pi./res;
% if any(s<=1)
%   error('The resolution is to big.')
% end
% 
% 
% shiftGrid = get_option(varargin,'shiftGrid',[0,0]);
% if check_option(varargin,'shiftGrid')
%   s = s-1;
% end
% 
% 
% 
% % compute ghat -> k x j x l
% % with  k = -N:N
% %       j = -N:N    -> use ghat(k,-j,l) = (-1)^(k+l) * ghat(k,-j,l)   (*)
% %       l =  0:N    -> use ghat(-k,-j,-l) = conj(ghat(k,j,l))        (**)
% % flags: 2^0 -> use L_2-normalized Wigner-D functions
% %        2^2 -> fhat are the fourier coefficients of a real valued function
% %        2^4 -> use right and left symmetry
% flags = 2^0+2^2+2^4;
% sym = [min(SO3F.SRight.multiplicityPerpZ,2),SO3F.SRight.multiplicityZ,...
%        min(SO3F.SLeft.multiplicityPerpZ,2),SO3F.SLeft.multiplicityZ];
% ghat = representationbased_coefficient_transform(N,SO3F.fhat,flags,sym);
% ghat = symmetriseFourierCoefficients(ghat,flags,SO3F.SRight,SO3F.SLeft,sym);
% ghat = permute(ghat,[3,2,1]);
% % correct ghat by i^(-k+l)
% z = - (0:N)'+ reshape(-N:N,1,1,[]) + shift * (0:N)';
% ghat = ghat.*(1i).^z;
% 
% if check_option(varargin,'shiftGrid')
%   ghat = ghat.*exp(-1i * (shiftGrid(1)*(0:N)' + shiftGrid(2)*(-N:N)) );
% end
% 
% 
% % use rotational symmetries around Z-axis to speed up (cut zeros in ghat)
% SRightZ = SO3F.SRight.multiplicityZ;
% SLeftZ = SO3F.SLeft.multiplicityZ;
% H(1) = H(1) / SLeftZ;
% if SLeftZ>1 || SRightZ>1
%   ind1 =  (0:SLeftZ:N)+1;
%   ind3 =  [-flip(SRightZ:SRightZ:N),(0:SRightZ:N)] + (N+1);
%   ghat = ghat(ind1,:,ind3);
% end
% 
% 
% % For small H we go through a smaller FFT(H) several times. Hence we reduce 
% % the size of the fourier coefficient matrix ghat by adding the coefficients 
% % with same complex exponentials.
% sz = size(ghat,1,2);
% if any(H<sz)
%   dim = ceil(sz./H);
%   A = zeros([dim.*H,size(ghat,3)]);
%   A(1:size(ghat,1),1:2*N+1,1:size(ghat,3)) = ghat;
%   % Note that H(1) and H(2) should be bigger than 1 to avoid errors by squeezing
%   ghat = squeeze(sum(reshape(A,H(1),dim(1),H(2),dim(2),[]),[2,4]));
%   clear A;
% end
% 
% 
% 
% % Do 2-variate fft for all Euler angles gamma
% f = zeros([s+1,length(gamma)]);
% for g = 1:length(gamma)
%   exponentials = exp( -1i*gamma(g) * reshape([-flip(SRightZ:SRightZ:N),(0:SRightZ:N)],1,1,[]) );
%   A = sum(ghat.*exponentials,3);
%   % fft
%   f2 = fft2(A,H(1),H(2));
%   % cut beta to [0,pi]
%   if s(1) == H(1)
%     f2 = f2([1:s(1),1],1:s(2)+1);
%   else
%     f2 = f2(1:s(1)+1,1:s(2)+1);
%   end
%   % shift the summation of fft from [-|_N/r_|:|_N/r_|]x[-N:N]x[-|_N/s_|:|_N/s_|] to 
%   % [0:2*|_N/r_|]x[0:2N]x[0:2*|_N/s_|]. With r- & s-fold rotational symmetry
%   % around Z-axis and |_ ... _| denotes the round off operator.
%   z = (0:s(2)) * (N/H(2));    % oder fftshift
%   f(:,:,g) = 2*real( exp(2i*pi*z) .* f2 );
% end
% 
% 
% % compute the corresponding nodes
% if nargout>1
%   if check_option(varargin,'shiftGrid')
%     grid = combvec((0:s(1))*res(1)-shift*pi/2,(0:s(2))*res(2),gamma);
%     grid = grid + [shiftGrid,0];
%   else
%     grid = combvec((0:s(1))*res(1)-shift*pi/2,(0:s(2))*res(2),gamma);
%   end
%   if isa(oS,'phi1Sections')
%     grid = grid(:,[3,2,1]);
%     grid = orientation.byEuler(grid,'nfft',SO3F.SS,SO3F.CS);
%   else
%     grid = orientation.byEuler(grid,'nfft',SO3F.CS,SO3F.SS);
%   end
%   nodes = reshape(grid,size(f));
% end
% 
% end





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