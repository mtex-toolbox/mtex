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

if isempty(ori), g = vector3d; return; end

% extract bandwidth
L = min(component.bandwidth+1,get_option(varargin,'bandwidth',inf));
component.bandwidth = L;

% create plan
nfsoft_flags = 2^4;
plan = nfsoftmex('init',L,length(ori),nfsoft_flags,0,4,1000,2*ceil(1.5*L));

% set nodes
abg = Euler(ori,'nfft');
nfsoftmex('set_x',plan,abg.');

% node-dependent precomputation
nfsoftmex('precompute',plan);

%% step 1: f_phi1 
Ldim = deg2dim(double(L+1));
fhat = component.f_hat(1:Ldim);
for l = 1:L-1
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
for l = 1:L-1    
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

%% ------------------------ f_theta ---------------------------
fhat = zeros(size(fhat));
for l = 0:L-1
    
  [k1,k2] = meshgrid(-l:l,-l:l);
  ind = (deg2dim(l)+1):deg2dim(l+1);
  
  % b
  if l > 0
    fhat(ind) = k1(:) .* k2(:) ./ l./(l+1) .* component.f_hat(ind);
  end
  
  % c
  next = (deg2dim(l+1)+1):deg2dim(l+2);
  c  = (l+2)/(l + 1)/(2*l + 3) * sqrt(((l+1)^2 - k1.^2) .* ((l+1)^2 - k2.^2));
  fhat(ind) = fhat(ind) + c(:) .* component.f_hat(next(inner(l+1)));
    
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

g = (f_phi1 + cos(abg(:,2)) .* f_phi2) * vector3d.Z + ...
  (f_phi2 + cos(abg(:,2)) .* f_phi1) .* (ori' * vector3d.Z) + ...
  f_Phi .* rotate(vector3d.Y,abg(:,1));

end

%%
function id = inner(n)
 [k1,k2] = meshgrid(-n:n);
 id = abs(k1)<n & abs(k2)<n;
 id = id(:);
end

function testing

cs = crystalSymmetry('1');
ref = orientation.id(cs);
odf = unimodalODF(ref,'halfwidth',80*degree);

fodf = FourierODF(odf)

omega = linspace(0,40)
rot = rotation('axis',yvector,'angle',omega*degree)
rot = rotation('axis',yvector,'angle',5*degree)

odf.grad(rot)
fodf.grad(rot)


%plot(norm(odf.grad(rot))



end