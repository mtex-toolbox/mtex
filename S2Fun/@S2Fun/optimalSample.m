function v = optimalSample(sF,n,varargin)
% optimal discrete sampling points of a spherical density function
% 
% Description
% 
% |optimalSample| behaves similarly as |discreteSample| with the
% difference, that the sampling points are optimized to reproduce the input
% density function as perfect as possible. The price you pay is time.
% |optimalSample| computes the sampling points by solving a minimization
% problem, which becomes harder the more points you want to generate.  
%
% For more details, see 
% 
% Gräf, Manuel; Potts, Daniel; Steidl, Gabriele (2012). Quadrature Errors, Discrepancies, and Their Relations to Halftoning on the Torus and the Sphere. SIAM Journal on Scientific Computing, 34(5), A2760–A2791. doi:10.1137/100814731
% 
% Syntax
%   v = optimalSample(sF,n)
%   v = optimalSample(sF,v)
%   v = optimalSample(sF,n,'bandwidth',128)
%   v = optimalSample(sF,n,'itermax',1000,'tol',1e-4)
% 
% Input
%  sF - @S2Fun
%  n  - number of points
%  v  - @vector3d (starting nodes)
%  psi - @S2Kernel (Disposition-kernel)
%
% Output
%  v - @vector3d
%
% Options
%  bandwidth - harmonic degree to approximate (default = 128)
%  maxIter - for gradient descent (default = 5000)
%  tol - for gradient descent (default = 5e-4)
%  weights - weights of points
%

% polynomials should be integrated exactly until this bandwidth
bw = get_option(varargin,'bandwidth',128);

% optimal sample works only for S2FunHarmonic
sF = S2FunHarmonic(sF,'bandwidth',bw);
sF.bandwidth = bw;

% get starting points
if isa(n,'vector3d')
  v = n;
elseif sF.antipodal
  v = equispacedS2Grid('points',n,'antipodal');
else
  v = equispacedS2Grid('points',n);
  %v = discreteSample(f,M);
end
M = numel(v);
v = v(:);
  
% specify parameters for gradient method
maxIter = get_option(varargin,'maxIter',1000);
tol = get_option(varargin,'tol',0.01*degree);

% Define Restricted Distance Kernel
psi = S2RestrictedDistanceKernel(bw+1);

if sF.antipodal, psi.A(2:2:end) = 0; end

% get integral (mean) weight lambda and the weights-vector for the points
lambda = sum(sF);
c = get_option(varargin,'weights',ones(M,1)/M);

% initialize NFSFT
nfsftmex('precompute', bw+1, 1000, 1, 0);
plan1 = nfsftmex('init_advanced',bw,M,1);
plan2 = nfsftmex('init_advanced',bw+1,M,1);

% gradient method
resOld = J(v,c,sF,psi,lambda,plan1);

pC = progressCounter(maxIter);
for i = 1:maxIter
  % compute gradient of the functional
  if nargout==2
    [gV,gC] = grad_J(v,c,sF,psi,lambda,plan1,plan2);
  else
    gV = grad_J(v,c,sF,psi,lambda,plan1,plan2);
    gC = 0;
  end
  gNorm = sqrt(sum(norm(gV).^2));

  % line search with Armijo
  stepSize = 1;
  while true
    vNew = cos(stepSize)*v - sin(stepSize)*gV; % TODO: check gradient step
    cNew = max(0,c - stepSize * gC);  % projiziertes Gradientenverfahren
    resNew = J(vNew,cNew,sF,psi,lambda,plan1);

    if resNew <= resOld - 1e-4*stepSize*(gNorm.^2+norm(gC)^2) % Armijo Condition
      break;
    end
    
    stepSize = 0.5*stepSize;
    
    % --- Local Termination ---
    if stepSize < 1e-16
      error('Armijo failed.')
    end
  end

  % --- Global Termination ---
  if max(angle(v,vNew)) < tol && norm(c-cNew,'Inf')<tol
    v = vNew;
    c = cNew;
    break;
  end

  % update
  v = vNew;
  c = cNew;
  resOld = resNew;

  if mod(i,50)==0
    pauseline
    plot(vNew,'MarkerSize',5);
  end
    
  pC.show(i)

end

nfsftmex('finalize', plan1);
nfsftmex('finalize', plan2);

end


function res = J(v,c,f,psi,lambda,plan1)
% C = lambda*S2FunHarmonic.adjointNFSFT(v,c,'bandwidth',bw);
% psi = S2Kernel( sqrt(4*pi*(2*(0:psi.bandwidth)+1)).*sqrt(psi.A) );    % TODO: lambda_0 < 0 !!!
% C = conv(C-f,psi);
% res = norm(C).^2;

[theta,rho] = polar(v(:)); %#ok<POLAR>

% adjoint NFSFT
nfsftmex('set_x', plan1, double([rho(:).'; theta(:).']));
% nfsftmex('precompute_x',plan1);
nfsftmex('set_f',plan1,double(c));
nfsftmex('adjoint',plan1);
chat = nfsftmex('get_f_hat_linear',plan1);
C = lambda*S2FunHarmonic(chat);

% convolute with Distance kernel
psi = S2Kernel( sqrt(4*pi*(2*(0:psi.bandwidth)'+1)).*sqrt(psi.A) );
C = conv(C-f,psi);

% l2-norm
res = norm(C).^2;
end

function [tanV,tanC] = grad_J(v,c,f,psi,lambda,plan1,plan2)
% C = lambda*S2FunHarmonic.adjointNFSFT(v,c,'bandwidth',bw);
% C = 4*pi*conv(C-f,psi);
% tanV = 2*lambda*real(C.grad(v)).*c;

[theta,rho] = polar(v(:)); %#ok<POLAR>

% adjoint NFSFT
nfsftmex('set_x',plan1,double([rho(:).'; theta(:).']));
% nfsftmex('precompute_x',plan1);
nfsftmex('set_f',plan1,double(c));
nfsftmex('adjoint',plan1)
chat = nfsftmex('get_f_hat_linear',plan1);
C = lambda*S2FunHarmonic(chat);

% convolute with Distance kernel
psi = 4*pi*psi;
C = conv(C-f,psi);

% compute spherical gradient
g = C.grad;

% compute NFSFT componentwise
tanV = zeros(length(v),3);
nfsftmex('set_x',plan2,double([rho(:).'; theta(:).']));
% nfsftmex('precompute_x',plan2);
for i = 1:3
  nfsftmex('set_f_hat_linear',plan2,double(g.sF.fhat(:,i)));
  nfsftmex('trafo',plan2);
  tanV(:,i) = nfsftmex('get_f',plan2);
end

tanV = 2*lambda*real(vector3d(tanV).').*c;

if nargout==2
  tanC = 2*lambda*real( C.eval(v) );
end

end


function Test

% Example Manuel paper
q = [xvector,yvector,zvector];
f = S2FunHandle(@(x) real(exp(-5*acos(dot(x,q(1))).^2) + exp(-5*acos(dot(x,q(2))).^2) + exp(-5*acos(dot(x,q(3))).^2)) );
f2 = abs(S2Fun.smiley);

v = equispacedS2Grid('points',5000); v=v(:);
v = compactify(f,'bandwidth',400,'points',v,'maxIter',1000);

% plot solution
plot3d(f)
hold on
scatter3d(v,'MarkerSize',3,'MarkerEdgeColor','k','MarkerFaceColor','k')
hold off

end