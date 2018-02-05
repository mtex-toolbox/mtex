function g = grad(component,ori,varargin)
% gradient at orientation g
%
% Syntax
%   g = grad(component,ori)
%
% Input
%  component - @unimodalComponent
%  ori - @orientation
%
% Output
%  g - @vector3d
%
% Description
% general formula:
%
% 

if isempty(ori), f = []; return; end

% extract bandwidth
L = min(component.bandwidth,get_option(varargin,'bandwidth',inf));
Ldim = deg2dim(double(L+1));

% create plan
nfsoft_flags = 2^4;
plan = nfsoftmex('init',L+1,length(ori),nfsoft_flags,0,4,1000,2*ceil(1.5*L));

% set nodes
abg = Euler(ori,'nfft');
nfsoftmex('set_x',plan,abg.');

% node-dependent precomputation
nfsoftmex('precompute',plan);

%% step 1: f_phi1 
fhat = component.f_hat(1:Ldim);
for l = 1:L
  [k1,~] = meshgrid(-l:l,-l:l);
  ind = (deg2dim(l)+1):deg2dim(l+1);
  fhat(ind) = -1i * k1 .* reshape(fhat(ind),2*l+1,2*l+1);
end
  
% set Fourier coefficients
nfsoftmex('set_f_hat',plan,fhat);
  
% transform
nfsoftmex('trafo',plan);

% get function values
f_phi1 = nfsoftmex('get_f',plan);

%% step 2: f_phi2
fhat = component.f_hat(1:Ldim);
for l = 1:L    
  [~,k2] = meshgrid(-l:l,-l:l);
  ind = (deg2dim(l)+1):deg2dim(l+1);
  fhat(ind) = -1i * k2 .* reshape(fhat(ind),2*l+1,2*l+1);  
end
  
% set Fourier coefficients
nfsoftmex('set_f_hat',plan,fhat);
  
% transform
nfsoftmex('trafo',plan);

% get function values
f_phi2 = nfsoftmex('get_f',plan);

%% ------------------------ f_Phi ---------------------------
fhat = zeros();
for l = 1:L
    
  [k1,k2] = meshgrid(-l:l,-l:l);
  ind = (deg2dim(l)+1):deg2dim(l+1);
  
  % b
  fhat(ind) = k1 .* k2 ./ n./(n+1) .* component.f_hat(ind);
  
  % a_n-1
  a = (n-1)/n*(2*n-1) * sqrt((n^2 - k1.^2) .* (n^2 - k2.^2));
  fhat(ind) = fhat(ind) + a .* fhat(pre);
  
  % c
  c  = (n+1)/(n + 2)*(2*n + 3) * sqrt(((n+1)^2 - k1.^2) .* ((n+1)^2 - k2.^2));
  fhat(ind) = fhat(ind) + a .* fhat(next);
  
end
  
% set Fourier coefficients
nfsoftmex('set_f_hat',plan,fhat);
  
% transform
nfsoftmex('trafo',plan);

% get function values
f_Phi = nfsoftmex('get_f',plan) ./ sin(abg(:,2));

% kill plan
nfsoftmex('finalize',plan);

%% combine result

g = f_phi1 * vector3d.Z + ...
  f_phi2 .* (ori * vector3d.Z) + ...
  f_Phi .* rotate(vector3d.Y,abg(:,1));

end
