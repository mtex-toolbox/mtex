function g = grad(SO3F,varargin)
% right-sided gradient of an SO3Fun
%
% Syntax
%   G = SO3F.grad % compute the gradient
%   g = SO3F.grad(rot) % evaluate the gradient in rot
%
%   % go 5 degree in direction of the gradient
%   ori_new = exp(rot,5*degree*normalize(g)) 
%
% Input
%  SO3F - @SO3FunHarmonic
%  rot  - @rotation / @orientation
%
% Output
%  G - @SO3VectorFieldHarmonic
%  g - @vector3d
% 

% fallback to generic method
if check_option(varargin,'check')
  g = grad@SO3Fun(SO3F,varargin{:});
  return
end

if nargin>1 && isa(varargin{1},'rotation') && isempty(varargin{1})
  g = vector3d; 
  return
end

% if bandwidth is zero there is nothing to do
if SO3F.bandwidth == 0 
  if nargin>1
    g = vector3d.zeros(size(varargin{1}));
  else
    g = SO3FunHarmonic(0);
  end
  return; 
end

fhat = ones(deg2dim(SO3F.bandwidth),3);
for n=0:SO3F.bandwidth
  ind = deg2dim(n)+1:deg2dim(n+1);
  FHAT = reshape(SO3F.fhat(ind),2*n+1,2*n+1);
  
  % compute derivative of Wigner-d functions
  k = (-n:n-1)';
  dd = (-1).^(k<0) .* sqrt((n+k+1).*(n-k))/2;

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

g = SO3VectorFieldHarmonic( SO3FunHarmonic(fhat,crystalSymmetry,SO3F.SS) );

if nargin > 1 && isa(varargin{1},'rotation')
  ori = varargin{1};
  g = vector3d(g.eval(ori).').';
end

end



% function [g,f_phi1,f_Phi,f_phi2] = grad(SO3F,ori,varargin)
% 
% % fallback to generic method
% if check_option(varargin,'check')
%   g = grad@SO3Fun(SO3F,varargin{:});
%   return
% end
% 
% if isempty(ori), g = vector3d; return; end
% 
% % if bandwidth is zero there is nothing to do
% if SO3F.bandwidth == 0, g = vector3d.zeros(size(ori)); return; end
% 
% % extract bandwidth
% L = min(SO3F.bandwidth+1,get_option(varargin,'bandwidth',inf));
% SO3F.bandwidth = L;
% 
% % 2^4 -> nfsoft-represent
% % 2^2 -> nfsoft-use-DPT
% nfsoft_flags = 2^2;
% 
% % change Fourier coefficients such that we can work with standard convention
% for l = 1:L
%   
%  [k1,k2] = meshgrid(-l:l,-l:l);
%  k1(k1>0) = 0;
%  k2(k2>0) = 0;
%  s = (-1).^k1 .* (-1).^k2 .* reshape((-1).^((1:(2*l+1)^2)-1),2*l+1,2*l+1);
%   
%  ind = (deg2dim(l)+1):deg2dim(l+1);
%  SO3F.fhat(ind) = s.*reshape(SO3F.fhat(ind),2*l+1,2*l+1);
% end
% 
% % create plan
% %nfsoft_flags = 4;
% plan = nfsoftmex('init',L,length(ori),nfsoft_flags,0,4,1000,2*ceil(1.5*L));
% 
% % set nodes
% abg = Euler(ori,'nfft');
% abg(abs(abg(:,2))<0.0001,2) = 0.0001; % avoid zero beta angle as we are going to divide by it
% nfsoftmex('set_x',plan,abg.');
% 
% % node-dependent precomputation
% nfsoftmex('precompute',plan);
% 
% 
% %% step 1: f_phi1 
% Ldim = deg2dim(double(L+1));
% fhat = SO3F.fhat(1:Ldim);
% for l = 0:L-1
%   [k1,~] = meshgrid(-l:l,-l:l);
%   ind = (deg2dim(l)+1):deg2dim(l+1);
%   fhat(ind) = -1i * k1(:) .* fhat(ind);
% end
%   
% % set Fourier coefficients
% nfsoftmex('set_f_hat',plan,fhat);
%   
% % transform
% nfsoftmex('trafo',plan);
% 
% % get function values
% f_phi1 = nfsoftmex('get_f',plan);
% 
% %% step 2: f_phi2
% fhat = SO3F.fhat(1:Ldim);
% for l = 0:L-1    
%   [~,k2] = meshgrid(-l:l,-l:l);
%   ind = (deg2dim(l)+1):deg2dim(l+1);
%   fhat(ind) = -1i * k2(:) .* fhat(ind);  
% end
%   
% % set Fourier coefficients
% nfsoftmex('set_f_hat',plan,fhat);
%   
% % transform
% nfsoftmex('trafo',plan);
% 
% % get function values
% f_phi2 = nfsoftmex('get_f',plan);
% 
% %% step 3: f_theta 
% fhat = zeros(size(fhat));
% for l = 0:L-1
%     
%   [k1,k2] = meshgrid(-l:l,-l:l);
%   ind = (deg2dim(l)+1):deg2dim(l+1);
%   
%   % b
%   if l > 0
%     fhat(ind) = -k1(:) .* k2(:) ./ l./(l+1) .* SO3F.fhat(ind);
%   end
%   
%   % c
%   next = (deg2dim(l+1)+1):deg2dim(l+2);
%   c  = (l+2)/(l + 1)/(2*l + 3) * sqrt(((l+1)^2 - k1.^2) .* ((l+1)^2 - k2.^2));
%   fhat(ind) = fhat(ind) - c(:) .* SO3F.fhat(next(inner(l+1)));
%     
%   % a_n-1
%   if l > 0
%     last = (deg2dim(l-1)+1):deg2dim(l);
%     a = (l-1)/l/(2*l-1) * sqrt((l^2 - k1.^2) .* (l^2 - k2.^2));
%     fhat(ind(inner(l))) = fhat(ind(inner(l))) + a(inner(l)) .* SO3F.fhat(last);
%   end
% end
%   
% % set Fourier coefficients
% nfsoftmex('set_f_hat',plan,fhat);
%   
% % transform
% nfsoftmex('trafo',plan);
% 
% % get function values
% f_Phi = nfsoftmex('get_f',plan) ./ sin(abg(:,2));
% 
% % kill plan
% nfsoftmex('finalize',plan);
% 
% %% combine result
% % by applying the metric tensor 
% 
% g = vector3d((real(f_phi1 - cos(abg(:,2)) .* f_phi2) .* (ori' * vector3d.Z) + ...
%   real(f_phi2 - cos(abg(:,2)) .* f_phi1) .* (vector3d.Z)) ./ sin(abg(:,2)).^2) + ...
%   real(f_Phi) .* rotate(vector3d.Y,-abg(:,3));
% 
% %if max(abs(f_phi1)) < 1e-5, disp('f_phi1 == 0'); end
% %if max(abs(f_phi2)) < 1e-5, disp('f_phi2 == 0'); end
% %if max(abs(f_Phi)) < 1e-5, disp('f_Phi == 0'); end
% 
% end
% 
% %%
% function id = inner(n)
%  [k1,k2] = meshgrid(-n:n);
%  id = abs(k1)<n & abs(k2)<n;
%  id = id(:);
% end
