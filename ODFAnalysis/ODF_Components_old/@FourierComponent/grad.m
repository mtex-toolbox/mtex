function [g,f_phi1,f_Phi,f_phi2] = grad(component,ori,varargin)
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

if isempty(ori), g = vector3d; return; end

% fallback to generic method
if check_option(varargin,'check')
  g = grad@ODFComponent(component,ori,varargin{:});
  return
end

% if bandwidth is zero there is nothing to do
if component.bandwidth == 0, g = vector3d.zeros(size(ori)); return; end

% extract bandwidth
L = min(component.bandwidth+1,get_option(varargin,'bandwidth',inf));
component.bandwidth = L;

% 2^4 -> nfsoft-represent
% 2^2 -> nfsoft-use-DPT
nfsoft_flags = 2^2;

% change Fourier coefficients such that we can work with standard convention
for l = 1:L
  
 [k1,k2] = meshgrid(-l:l,-l:l);
 k1(k1>0) = 0;
 k2(k2>0) = 0;
 s = (-1).^k1 .* (-1).^k2 .* reshape((-1).^((1:(2*l+1)^2)-1),2*l+1,2*l+1);
  
 ind = (deg2dim(l)+1):deg2dim(l+1);
 component.f_hat(ind) = s.*reshape(component.f_hat(ind),2*l+1,2*l+1);
end

% create plan
%nfsoft_flags = 4;
plan = nfsoftmex('init',L,length(ori),nfsoft_flags,0,4,1000,2*ceil(1.5*L));

% set nodes
abg = Euler(ori,'nfft');
abg(abs(abg(:,2))<0.0001,2) = 0.0001; % avoid zero beta angle as we are going to divide by it
nfsoftmex('set_x',plan,abg.');

% node-dependent precomputation
nfsoftmex('precompute',plan);


%% step 1: f_phi1 
Ldim = deg2dim(double(L+1));
fhat = component.f_hat(1:Ldim);
for l = 0:L-1
  [k1,~] = meshgrid(-l:l,-l:l);
  ind = (deg2dim(l)+1):deg2dim(l+1);
  fhat(ind) = -1i * k1(:) .* fhat(ind);
end
  
% set Fourier coefficients
nfsoftmex('set_f_hat',plan,fhat);
  
% transform
nfsoftmex('trafo',plan);

% get function values
f_phi1 = nfsoftmex('get_f',plan);

%% step 2: f_phi2
fhat = component.f_hat(1:Ldim);
for l = 0:L-1    
  [~,k2] = meshgrid(-l:l,-l:l);
  ind = (deg2dim(l)+1):deg2dim(l+1);
  fhat(ind) = -1i * k2(:) .* fhat(ind);  
end
  
% set Fourier coefficients
nfsoftmex('set_f_hat',plan,fhat);
  
% transform
nfsoftmex('trafo',plan);

% get function values
f_phi2 = nfsoftmex('get_f',plan);

%% step 3: f_theta 
fhat = zeros(size(fhat));
for l = 0:L-1
    
  [k1,k2] = meshgrid(-l:l,-l:l);
  ind = (deg2dim(l)+1):deg2dim(l+1);
  
  % b
  if l > 0
    fhat(ind) = -k1(:) .* k2(:) ./ l./(l+1) .* component.f_hat(ind);
  end
  
  % c
  next = (deg2dim(l+1)+1):deg2dim(l+2);
  c  = (l+2)/(l + 1)/(2*l + 3) * sqrt(((l+1)^2 - k1.^2) .* ((l+1)^2 - k2.^2));
  fhat(ind) = fhat(ind) - c(:) .* component.f_hat(next(inner(l+1)));
    
  % a_n-1
  if l > 0
    last = (deg2dim(l-1)+1):deg2dim(l);
    a = (l-1)/l/(2*l-1) * sqrt((l^2 - k1.^2) .* (l^2 - k2.^2));
    fhat(ind(inner(l))) = fhat(ind(inner(l))) + a(inner(l)) .* component.f_hat(last);
  end
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
% by applying the metric tensor 

g = vector3d((real(f_phi1 - cos(abg(:,2)) .* f_phi2) .* (ori' * vector3d.Z) + ...
  real(f_phi2 - cos(abg(:,2)) .* f_phi1) .* (vector3d.Z)) ./ sin(abg(:,2)).^2) + ...
  real(f_Phi) .* rotate(vector3d.Y,-abg(:,3));

%if max(abs(f_phi1)) < 1e-5, disp('f_phi1 == 0'); end
%if max(abs(f_phi2)) < 1e-5, disp('f_phi2 == 0'); end
%if max(abs(f_Phi)) < 1e-5, disp('f_Phi == 0'); end

end

%%
function id = inner(n)
 [k1,k2] = meshgrid(-n:n);
 id = abs(k1)<n & abs(k2)<n;
 id = id(:);
end
