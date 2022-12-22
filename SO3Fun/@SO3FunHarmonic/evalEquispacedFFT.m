function [f,nodes] = evalEquispacedFFT(SO3F,varargin)
% Evaluate an @SO3FunHarmonic on an equispaced grid in Euler angles
%     $$(\alpha_a,\beta_b,\gamma_c) = (\frac{2\pi a}{H_1},\frac{\pi b}{H_2-1},\frac{2\pi c}{H_3})$$
% where $a=0,...,H_1-1$, $b=0,...,H_2-1$ and $c=0,...,H_3-1$.
%
% Therefore we transform the SO(3) Fourier series to an usual Fourier series
% equivalent as in the function <SO3FunHarmonic.evalV2.html |evalV2|>.
% But we use an equispaced FFT instead of the NFFT.
%
% Syntax
%   f = evalEquispacedFFT(SO3F)
%   f = evalEquispacedFFT(SO3F,'GridPointNum',30)
%   f = evalEquispacedFFT(SO3F,'resolution',2.5*degree)
%   [f,nodes] = evalEquispacedFFT(SO3F,'GridPointNum',[20,30,40])
%
% Input
%  SO3F - @SO3FunHarmonic
%
% Output
%  f - values at this grid points
%  nodes - @orientation
%
% See also
% SO3FunHarmonic/evalV2 SO3FunHarmonic/evalSectionsEquispacedFFT SO3FunHarmonic/eval

N = SO3F.bandwidth;



if check_option('resolution')
  % get grid size along 1st and 2nd Euler angles
  res = get_option(varargin,'resolution',2.5*degree);
  if length(res)==1
    res = [1,1,1]*res;
  end
  % [a_max,b_max,~] = fundamentalRegionEuler(SO3F.CS,SO3F.SS);
  s = ceil([a_max,b_max]./res);
  res = [a_max,b_max]./s;
  H = 2*pi./res;
  if any(s<=1)
    error('The resolution is to big.')
  end
else
  % get number of grid points
  H = get_option(varargin,'GridPointNum',2*N+2);
  if length(H)==1
    H = [1,1,1]*H;
  else
    H(2) = 2*(H(2)-1);
  end
  % Grid point number has to be even along second Euler angle, to guarantee that beta=pi is a grid point
  if mod(H(2),2)==1
    H(2) = 2*H(2);
  end
  if H(1)<=1 || H(2)<=1 || H(3)<=0
    error('The number of grid points is to small.')
  end
end



if SO3F.isReal

  % create ghat -> k x j x l
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
  ghat = permute(ghat,[3,2,1]);
  % correct ghat by i^(-k+l)
  z = - (0:N)'+ reshape(-N:N,1,1,[]);
  ghat = ghat.*(1i).^z;

else

  % compute ghat
  % flags: 2^0 -> use L_2-normalized Wigner-D functions
  %        2^4 -> use right and left symmetry
  flags = 2^0+2^4;
  sym = [min(SO3F.SRight.multiplicityPerpZ,2),SO3F.SRight.multiplicityZ,...
         min(SO3F.SLeft.multiplicityPerpZ,2),SO3F.SLeft.multiplicityZ];
  ghat = representationbased_coefficient_transform(N,SO3F.fhat,flags,sym);
  ghat = permute(ghat,[3,2,1]);
  % correct ghat by i^(-k+l)
  z = - (-N:N)' + reshape(-N:N,1,1,[]);
  ghat = ghat.*(1i).^z;

end



% use rotational symmetries around Z-axis to speed up (cut zeros in ghat)
SRightZ = SO3F.SRight.multiplicityZ;
if mod(H(3),SRightZ)~=0
  if mod(SRightZ,2)==0 && mod(H(3),2)==0
    SRightZ = 2;
  elseif mod(SRightZ,3)==0 && mod(H(3),3)==0
    SRightZ = 3;
  else
    SRightZ = 1;
  end
end
SLeftZ = SO3F.SLeft.multiplicityZ;
if mod(H(1),SLeftZ)~=0 || H(1)<=SLeftZ  
  if mod(SLeftZ,2)==0 && mod(H(3),2)==0
    SLeftZ = 2;
  elseif mod(SLeftZ,3)==0 && mod(H(3),3)==0
    SLeftZ = 3;
  else
    SLeftZ = 1;
  end
end
H(1) = H(1) / SLeftZ;
H(3) = H(3) / SRightZ;
if SLeftZ>1 || SRightZ>1
  if SO3F.isReal
    ind1 =  (0:SLeftZ:N)+1;
  else
    ind1 =  [-flip(SLeftZ:SLeftZ:N),(0:SLeftZ:N)] + (N+1);
  end
  ind3 =  [-flip(SRightZ:SRightZ:N),(0:SRightZ:N)] + (N+1);
  ghat = ghat(ind1,:,ind3);
end

% For small H we go through a smaller FFT(H) several times. Hence we reduce 
% the size of the fourier coefficient matrix ghat by adding the coefficients 
% with same complex exponentials.
sz = size(ghat,1,2,3);
if any(H<sz)
  dim = ceil(sz./H);
  B = zeros(dim.*H);
  B(1:size(ghat,1),1:2*N+1,1:size(ghat,3)) = ghat;
  % Note that H(1) and H(2) should be biger than 1 to avoid errors by squeezing
  ghat = squeeze(sum(reshape(B,H(1),dim(1),H(2),dim(2),H(3),dim(3)),[2,4,6]));
end


% fft
f = fftn(ghat,H);
% cut beta to [0,pi]
f = f(:,1:H(2)/2+1,:);
% shift the summation of fft from [-|_N/r_|:|_N/r_|]x[-N:N]x[-|_N/s_|:|_N/s_|] to 
% [0:2*|_N/r_|]x[0:2N]x[0:2*|_N/s_|]. With r- & s-fold rotational symmetry
% around Z-axis and |_ ... _| denotes the round off operator.
if SO3F.isReal
  z = (0:H(2)/2) * (N/H(2)) + reshape(0:H(3)-1,1,1,[]) * (floor(N/SRightZ)/H(3));
  f = 2*real( exp(2i*pi*z) .* f );
else
  z = (0:H(1)-1)' * (floor(N/SLeftZ)/H(1)) + (0:H(2)/2) * (N/H(2)) + reshape(0:H(3)-1,1,1,[]) * (floor(N/SRightZ)/H(3));
  f = exp(2i*pi*z) .* f;
end


% nodes
if nargout>1
  grid = combvec(0:H(1)-1,0:H(2)-1,0:H(3)-1)' .* ([2*pi/SLeftZ,2*pi,2*pi/SRightZ] ./ H);
  grid = grid(grid(:,2)<=pi,:);
  grid = orientation.byEuler(grid,'nfft',SO3F.CS,SO3F.SS);
  nodes = reshape(grid,size(f));
end



end