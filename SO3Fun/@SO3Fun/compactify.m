function [ori,c] = compactify(f,varargin)
% compute the compactification of an given function on the Rotation Group. That
% means, we try to find a in some sense optimal set of orientations, that
% describes the given density function reasonable well. This is similar to
% the so called halftoning problem.
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
%  f - @SO3Fun
%  ori - @rotation (starting nodes)
%  psi - @SO3Kernel (Disposition-kernel)
%
% Output
%  ori - @rotation
%
% Options
%  points - specify number of output points (default = 1000)
%  bandwidth - harmonic degree to approximate (default = 32)
%  maxIter - for gradient descent (default = 100)
%  tol - for gradient descent (default = 5e-4)
%  weights - weights of points
%
%


% TODO: Symmetries and input is orientation
% TODO: antipodal

% polynomials should be integrated exactly until this bandwidth
bw = get_option(varargin,'bandwidth',32);

% load density function
f = SO3FunHarmonic(f,'bandwidth',bw);
f.bandwidth = bw;

% get starting points
M = get_option(varargin,'points',1000);
if isa(M,'rotation')
  ori = M;
else
  ori = equispacedSO3Grid(crystalSymmetry,'points',M)';
  %ori = discreteSample(f,M);
end
M = numel(ori);
ori = ori(:);
  
% specify parameters for gradient method
maxIter = get_option(varargin,'maxIter',100);
tol = get_option(varargin,'tol',5e-4);

% Define Restricted Distance Kernel
psi = get_option(varargin,'kernel',SO3RestrictedDistanceKernel(bw+1));


% get integral (mean) weight lambda and the weights-vector for the points
lambda = sum(f);
c = get_option(varargin,'weights',ones(M,1)/M);
c = c(:);

% gradient method
resOld = J(ori,c,f,psi,lambda,bw);

pC = progressCounter(maxIter);
for i = 1:maxIter
  % compute gradient of the functional
  g = grad_J(ori,c,f,psi,lambda,bw);

  gNorm = sqrt(sum(norm(g).^2));

  % line search with Armijo
  stepSize = 1;
  while true
    % gradient step
    oriNew = exp(-stepSize*g,ori);   % exp(-stepSize*g./norm(g),ori); doesn't make sense for me

    resNew = J(oriNew,c,f,psi,lambda,bw);

    if resNew < resOld - 1e-4*stepSize*gNorm.^2 % Armijo Condition
      break;
    end

    stepSize = 0.5*stepSize;

    % --- Local Termination ---
    if stepSize < 1e-10
      error('Armijo failed.')
    end
  end

  % --- Global Termination ---
  if max(angle(ori,oriNew)) < tol
    ori = oriNew;
    break;
  end

  % update
  ori = oriNew;
  resOld = resNew;
  
  pC.show(i)

end


end


function res = J(ori,c,f,psi,lambda,bw)

  % adjoint NFSOFT
  C = lambda * 1/(sqrt(8)*pi) * SO3FunHarmonic.adjointNFSOFT(ori,c,'bandwidth',bw);

  % convolute with Distance kernel
  psi = (sqrt(8)*pi) * SO3Kernel( sqrt(2*(0:psi.bandwidth)+1).*sqrt(psi.A) );   % TODO: lambda_0 < 0 !!!!
  C = conv(C - (sqrt(8)*pi)*f,psi);
    
  % l2-norm
  res = norm(C).^2;
end



function tanV = grad_J(ori,c,f,psi,lambda,bw)

  % adjoint NFSOFT
  C = lambda * 1/(sqrt(8)*pi) * SO3FunHarmonic.adjointNFSOFT(ori,c,'bandwidth',bw);

  % convolute with Distance kernel
  C = conv( C - (sqrt(8)*pi)*f , (8*pi^2) * psi);

  % evaluate rotational gradient on ori
  tanV = 2*lambda*real( 1/(sqrt(8)*pi) * C.grad(ori) ).*c;

end



function Test
  

clear
setMTEXpref('EulerAngleConvention','Bunge')


% Example 1
f = SO3FunRBF(rotation.byEuler(pi,pi/2,90*degree,'ZXZ'),SO3DeLaValleePoussinKernel(3));
f = f/mean(f);

% Example 2
f = SO3Fun.dubna;
f.CS =crystalSymmetry.default;
f = SO3FunHarmonic(f);

rot0 = equispacedSO3Grid(crystalSymmetry,'points',1000);
rot0 = rot0(:);
% rot0 = discreteSample(f,1000);

hold off
plot(f,'phi2',207*degree)
hold on
rot = rot0*rotation.byAxisAngle(vector3d(1,1,1),0.001*degree);
plot(rot)
pause(1)
for i = 1:10
  rot = compactify(f,'bandwidth',50,'points',rot,'maxIter',10);
  plot(rot)
  pause(1)
end
hold off

end