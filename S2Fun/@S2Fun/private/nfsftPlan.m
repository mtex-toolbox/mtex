function T = nfsftPlan(bw,M)
% reusable NFSFT plans of fixed bandwidth and number of nodes
%
% Description
%
% |nfsftPlan| bundles the nonequispaced fast spherical Fourier transforms
% that the iterative method <S2Fun.optimalSample.html |optimalSample|> needs
% into a set of function handles which share a pair of |nfsftmex| plans.
%
% In contrast to <S2FunHarmonic.eval.html |S2FunHarmonic/eval|> and
% <S2FunHarmonic.adjointNFSFT.html |S2FunHarmonic.adjointNFSFT|> the plans
% are set up only once, while the nodes are updated in place. Those methods
% instead run the global |precompute| of |nfsftmex| and build a new plan on
% every single call, which dominates the run time as soon as some thousand
% transforms are required.
%
% Three plans are kept: one of bandwidth |bw| for the density function and
% the discrete measure, one of bandwidth |bw+1| for the components of a
% spherical gradient, which is of one degree higher, and one of bandwidth
% |bw+2| for the components of a second gradient, i.e. a Hessian. The third
% plan is created on first use, so that a caller which never asks for a
% Hessian does not pay for it.
%
% Syntax
%   T = nfsftPlan(bw,M)
%
%   T.setNodes(v)        % update the nodes of all plans
%   fhat = T.adjoint(c)  % coefficients of the measure sum_j c_j delta_{v_j}
%   y = T.trafo(fhat)    % evaluate the harmonic series fhat in the nodes
%   g = T.grad(sF)       % evaluate the gradient of sF in the nodes
%   [g,S] = T.gradHess(sF) % the same together with the Hessian of sF
%   T.finalize()         % free the plans
%
% Input
%  bw - bandwidth
%  M  - number of nodes
%
% Output
%  T - struct of function handles
%
% Note
% The plans are a resource of the |nfsftmex| library and are not freed
% automatically. Wrap |T.finalize| into an |onCleanup| object, so that they
% are freed even if the caller is interrupted by Ctrl-C.
%
% Note
% While the plans are alive, nothing may call |S2FunHarmonic/eval|,
% |S2FunHarmonic/evalNFSFT| or |S2FunHarmonic.adjointNFSFT| - each of them
% runs the global |precompute| again, which discards the wisdom the live
% plans are built on. Pure coefficient recursions such as |S2Kernel/conv| and
% |S2FunHarmonic/grad| are safe.
%
% See also
% S2Fun/optimalSample S2Fun/optimalSampleNewton S2FunHarmonic/evalNFSFT

% Global precomputation of the polynomial transform, covers all three plans.
% It has to state the largest degree any of them will ever use, i.e. bw+2 and
% not bw+1, even if no Hessian is ever asked for: nfsftmex('precompute')
% discards the previous wisdom and thereby invalidates every plan that is
% currently alive, hence it must not be called a second time later on. The
% additional degree is free in practice, since the transform rounds up to a
% power of two anyway.
nfsftmex('precompute',bw+2,1000,1,0);

planF = nfsftmex('init_advanced',bw,M,1);
planG = nfsftmex('init_advanced',bw+1,M,1);

% bandwidth bw+2, created on the first call of gradHess
planH = [];

% polar coordinates of the nodes currently set in the plans
X = [];

T = struct('setNodes',@setNodes,'adjoint',@adjoint,'trafo',@trafo, ...
  'grad',@gradTrafo,'gradHess',@gradHessTrafo,'finalize',@finalize);

  function setNodes(v)
    % Set the nodes of all plans. Repeated calls with the same nodes are
    % free, which allows the caller to state the nodes it works on instead
    % of tracking the state of the plans.

    [theta,rho] = polar(v(:)); %#ok<POLAR>
    Xnew = double([rho(:).'; theta(:).']);

    if isequal(Xnew,X), return, end

    X = Xnew;
    nfsftmex('set_x',planF,X);
    nfsftmex('set_x',planG,X);
    if ~isempty(planH), nfsftmex('set_x',planH,X); end
  end

  function fhat = adjoint(c)
    % adjoint NFSFT, i.e. the harmonic coefficients of the discrete measure
    % sum_j c_j delta_{v_j} up to degree bw

    nfsftmex('set_f',planF,double(c(:)));
    nfsftmex('adjoint',planF);
    fhat = nfsftmex('get_f_hat_linear',planF);
  end

  function y = trafo(fhat)
    % NFSFT, i.e. evaluate the harmonic series with coefficients fhat in the
    % nodes

    nfsftmex('set_f_hat_linear',planF,double(fhat(:)));
    nfsftmex('trafo',planF);
    y = nfsftmex('get_f',planF);
  end

  function fhat = gradCoeff(sF)
    % harmonic coefficients of the spherical gradient of sF, i.e. three
    % series of one degree higher than sF in the canonical basis. Restore
    % that length in case the highest degrees of sF, and hence of its
    % gradient, vanish.

    G = sF.grad;
    G.bandwidth = sF.bandwidth+1;
    fhat = G.sF.fhat;
  end

  function y = trafoBW(plan,fhat)
    % evaluate a single harmonic series in the nodes of the given plan

    nfsftmex('set_f_hat_linear',plan,double(fhat(:)));
    nfsftmex('trafo',plan);
    y = real(nfsftmex('get_f',plan));
  end

  function g = gradTrafo(sF)
    % evaluate the spherical gradient of the S2FunHarmonic sF in the nodes.
    % Being of one degree higher than sF, it requires the second plan.

    fhatG = gradCoeff(sF);

    g = vector3d(trafoBW(planG,fhatG(:,1)), ...
      trafoBW(planG,fhatG(:,2)), trafoBW(planG,fhatG(:,3)));
  end

  function [g,S] = gradHessTrafo(sF)
    % evaluate the spherical gradient and the Hessian of the S2FunHarmonic
    % sF in the nodes.
    %
    % Output
    %  g - @vector3d, the spherical gradient in the nodes
    %  S - M x 6, the symmetric part of the ambient matrix A(k,l) = (grad
    %      G_k)_l with G = grad sF, stored as [11 22 33 12 13 23]
    %
    % For an orthonormal tangent frame E = [e1 e2] at a node, the Riemannian
    % Hessian of sF in that frame is E'*S*E. No Christoffel correction is
    % needed: G is already the tangential gradient field, so A*u is the
    % derivative of G along a tangential u, and the projection of the
    % Levi-Civita connection is absorbed by testing against a tangential
    % vector. In contrast to the polar coordinate route of
    % <S2FunHarmonic.simultaniousCG.html |simultaniousCG|> this is free of
    % the cot(theta) singularity at the poles.
    %
    % A itself is not symmetric, its restriction to the tangent plane is.
    % Symmetrizing the coefficients before the transform is therefore
    % harmless and saves three of the nine transforms.

    fhatG = gradCoeff(sF);

    g = vector3d(trafoBW(planG,fhatG(:,1)), ...
      trafoBW(planG,fhatG(:,2)), trafoBW(planG,fhatG(:,3)));

    if isempty(planH)
      planH = nfsftmex('init_advanced',bw+2,M,1);
      if ~isempty(X), nfsftmex('set_x',planH,X); end
    end

    % Apply the gradient recursion a second time, component by component.
    % S2FunHarmonic/grad indexes fhat linearly and is not multivariate safe,
    % hence the loop is required and not an optimization.
    B = zeros((bw+3)^2,3,3);
    for k = 1:3
      Ak = S2FunHarmonic(fhatG(:,k)).grad;
      Ak.bandwidth = bw+2;
      B(:,k,:) = reshape(Ak.sF.fhat,[],1,3);
    end

    S = [trafoBW(planH,B(:,1,1)), trafoBW(planH,B(:,2,2)), ...
      trafoBW(planH,B(:,3,3)), trafoBW(planH,(B(:,1,2)+B(:,2,1))/2), ...
      trafoBW(planH,(B(:,1,3)+B(:,3,1))/2), ...
      trafoBW(planH,(B(:,2,3)+B(:,3,2))/2)];
  end

  function finalize()
    % free the plans, may be called more than once

    if ~isempty(planF), nfsftmex('finalize',planF); planF = []; end
    if ~isempty(planG), nfsftmex('finalize',planG); planG = []; end
    if ~isempty(planH), nfsftmex('finalize',planH); planH = []; end
  end

end
