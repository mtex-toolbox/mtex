function [ori,c] = optimalSample(f,n,varargin)
% optimal discrete sampling points of an orientation density function
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
%   ori = optimalSample(f)
%   ori = optimalSample(f,ori)
%   ori = optimalSample(f,n,'bandwidth',32)
%   ori = optimalSample(f,n,'maxIter',1000,'tol',0.05*degree)
% 
% Input
%  f - @SO3Fun
%  n - number of sampling points
%  ori - @rotation (starting nodes)
%
% Output
%  ori - @rotation
%
% Options
%  bandwidth - harmonic degree to approximate (default = 32)
%  maxIter - for gradient descent (default = 100)
%  tol - for gradient descent (default = 0.01*degree)
%  weights - weights of points
%

% TODO: Symmetries and input is orientation
% TODO: antipodal

% get starting points
if isa(n,'rotation')
  ori = n;
else
  %ori = equispacedSO3Grid(f.CS,f.SS,'points',n);
  ori = discreteSample(f,n);
end
M = numel(ori);
ori = ori(:);

% polynomials should be integrated exactly until this bandwidth
bw = get_option(varargin,'bandwidth',32);

% load density function
f = SO3FunHarmonic(f,'bandwidth',bw);
f.bandwidth = bw;

% specify parameters for gradient method
maxIter = get_option(varargin,'maxIter',100);
tol = get_option(varargin,'tol',0.1*degree);

% Define Restricted Distance Kernel
psi = SO3RestrictedDistanceKernel(bw+1);

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
    if stepSize < 1e-16
      error('Armijo failed.')
    end
  end
  % verbose output
  %disp(i + " stepsize: " + stepSize + "  gradient: " + stepSize*max(norm(g)) / degree + ...
  %  " error: " + resNew);


  % --- Global Termination ---
  % fprintf(['The biggest shift is ',num2str(max(angle(ori,oriNew))/degree),'°. In this iteration the Error changes by ',num2str(resOld - resNew),'\n'])
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
% In case of symmetries: The output SO3FunHarmonic C has to be symmetrised, which is already internally done in the construction of the SO3FunHarmonic.

% convolute with Distance kernel
psi = (sqrt(8)*pi) * SO3Kernel( sqrt(2*(0:psi.bandwidth)+1).*sqrt(psi.A) );   % TODO: lambda_0 < 0 !!!!
C = conv(C - (sqrt(8)*pi)*f,psi);

% l2-norm
res = norm(C).^2;
end



function tanV = grad_J(ori,c,f,psi,lambda,bw)

% adjoint NFSOFT
C = lambda * 1/(sqrt(8)*pi) * SO3FunHarmonic.adjointNFSOFT(ori,c,'bandwidth',bw);
% In case of symmetries: The output SO3FunHarmonic C has to be symmetrised, which is already internally done in the construction of the SO3FunHarmonic.

% convolute with Distance kernel
C = conv( C - (sqrt(8)*pi)*f , (8*pi^2) * psi);

% evaluate rotational gradient on ori
tanV = 2*lambda*real( 1/(sqrt(8)*pi) * C.grad(ori) ).*c;
% In case of symmetries: The output SO3FunHarmonic C has to be symmetrised, which is already internally done in the construction of the SO3FunHarmonic.
% The handling with the symmetries is slightly more difficult for the SO3VectorField-objects.

end


function Test
 
clear
setMTEXpref('EulerAngleConvention','Bunge')

% Example 1
f = SO3FunRBF(rotation.byEuler(pi,pi/2,90*degree,'ZXZ'),SO3DeLaValleePoussinKernel(3));
f = f/mean(f);

% Example 2
f = SO3Fun.dubna;
f = SO3FunHarmonic(f);

ori = compactify(f,'bandwidth',32,'points',100);

plot3d(f,'AxisAngle','complete')
hold on
plot(ori,'AxisAngle','all')
hold off


end