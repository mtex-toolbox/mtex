function [v,c] = compactify(f,varargin)
% compute the compactification of an given function on the Sphere.
% That means, we try to find a in some sense optimal set of orientations,
% that describes the given density function reasonable well.
% This is similar to the so called halftoning problem.
%
% Therefore, we solve a minimization problem by gradient descent method to 
% find a set of orientations, such that the corresponding worst case 
% quadrature error with respect to all spherical polynomials up to some 
% specified bandwidth is minimal. 
%
% For more details, see 
% 
% Gräf, Manuel; Potts, Daniel; Steidl, Gabriele (2012). Quadrature Errors, Discrepancies, and Their Relations to Halftoning on the Torus and the Sphere. SIAM Journal on Scientific Computing, 34(5), A2760–A2791. doi:10.1137/100814731
% 
%
%
% Syntax
%   v = compactify(f)
%   v = compactify(f,'points',v,'bandwidth',128)
%   v = compactify(f,'points',500,'itermax',1000,'tol',1e-4)
% 
% Input
%  f - @S2Fun
%  v - @vector3d (starting nodes)
%  psi - @S2Kernel (Disposition-kernel)
%
% Output
%  v - @vector3d
%
% Options
%  points - specify number of output points (default = 1000)
%  bandwidth - harmonic degree to approximate (default = 128)
%  maxIter - for gradient descent (default = 5000)
%  tol - for gradient descent (default = 5e-4)
%  weights - weights of points
%
%


% polynomials should be integrated exactly until this bandwidth
bw = get_option(varargin,'bandwidth',128);

% load density function
f = S2FunHarmonic(f,'bandwidth',bw);
f.bandwidth = bw;

% get starting points
M = get_option(varargin,'points',1000);
if isa(M,'vector3d')
  v = M;
else
  v = equispacedS2Grid('points',M)';
end
M = numel(v);
v = v(:);
  
% specify parameters for gradient method
maxIter = get_option(varargin,'maxIter',1000);
tol = get_option(varargin,'tol',5e-4);

% Define Restricted Distance Kernel
n = (0:bw+1);
% In the paper: psi = S2Kernel( 4./(2*n-1)./(2*n+3) ); is the same as S2KernelHandle(@(x) -2*sin(acos(x)/2)) in MTEX other normalization of coeffs 
psi = S2Kernel(16*pi./((2*n+1).*(2*n-1).*(2*n+3)));

% Get integral (mean) weight lambda and the weights-vector for the points
lambda = sum(f);
c = get_option(varargin,'weights',ones(M,1)/M);



% initialize NFSFT
nfsftmex('precompute', bw+1, 1000, 1, 0);
plan1 = nfsftmex('init_advanced',bw,M,1);
plan2 = nfsftmex('init_advanced',bw+1,M,1);

% gradient method
resOld = J(v,c,f,psi,lambda,plan1);
for i = 1:maxIter

  % compute gradient of the functional
  g = grad_J(v,c,f,psi,lambda,plan1,plan2);
  gNorm = sqrt(sum(norm(g).^2));

  % line search with Armijo
  stepSize = 1;
  while true
    vNew = cos(stepSize)*v - sin(stepSize)*g; % TODO: check gradient step
    
    resNew = J(vNew,c,f,psi,lambda,plan1);

    if resNew <= resOld - 1e-4*stepSize*gNorm.^2 % Armijo Condition
      break;
    end
    
    stepSize = 0.5*stepSize;
    
    % --- Local Termination ---
    if stepSize < 1e-10
      error('Armijo failed.')
    end
  end

  % --- Global Termination ---
  if max(angle(v,vNew)) < tol
    v = vNew;
    break;
  end

  % update
  v = vNew;
  resOld = resNew;

end

nfsftmex('finalize', plan1);
nfsftmex('finalize', plan2);

end


function res = J(v,c,f,psi,lambda,plan1)
    [theta,rho] = polar(v(:)); %#ok<POLAR>

    % adjoint NFSFT
    nfsftmex('set_x', plan1, [rho(:).'; theta(:).']);
    nfsftmex('precompute_x',plan1);
    nfsftmex('set_f',plan1,c);
    nfsftmex('adjoint',plan1);
    chat = nfsftmex('get_f_hat_linear',plan1);
    C = lambda*S2FunHarmonic(chat);

    % convolute with Distance kernel
    psi = S2Kernel( (2*(0:psi.bandwidth)+1).*sqrt(psi.A) );
    C = conv(C-f,psi);
    
    % l2-norm
    res = norm(C).^2;
end



function tanV = grad_J(v,c,f,psi,lambda,plan1,plan2)
    [theta,rho] = polar(v(:)); %#ok<POLAR>    
    
    % adjoint NFSFT 
    nfsftmex('set_x',plan1,[rho(:).'; theta(:).']);
    nfsftmex('precompute_x',plan1);
    nfsftmex('set_f',plan1,c);
    nfsftmex('adjoint',plan1)
    chat = nfsftmex('get_f_hat_linear',plan1);
    C = lambda*S2FunHarmonic(chat);

    % convolute with Distance kernel
    psi = S2Kernel( (2*(0:psi.bandwidth)+1).*psi.A );
    C = conv(C-f,psi);
       
    % compute spherical gradient
    g = C.grad;

    % compute NFSFT componentwise
    tanV = zeros(length(v),3);
    nfsftmex('set_x',plan2,[rho(:).'; theta(:).']);
    nfsftmex('precompute_x',plan2);
    for i = 1:3
        nfsftmex('set_f_hat_linear',plan2,g.sF.fhat(:,i));
        nfsftmex('trafo',plan2);
        tanV(:,i) = nfsftmex('get_f',plan2);
    end

    tanV = 2*lambda*real(vector3d(tanV).').*c;

end






























function Test
  
  % Example Manuel paper
  q = [xvector,yvector,zvector];
  f = S2FunHandle(@(x) real(exp(-5*acos(dot(x,q(1))).^2) + exp(-5*acos(dot(x,q(2))).^2) + exp(-5*acos(dot(x,q(3))).^2)) );

  v = equispacedS2Grid('points',5000); v=v(:);
  v = compactify(f,'bandwidth',400,'points',v,'maxIter',1000);

  % plot solution
  plot3d(f)
  hold on
  scatter3d(v,'MarkerSize',3,'MarkerEdgeColor','k','MarkerFaceColor','k')
  hold off

end