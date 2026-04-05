function odf = doEulerStep(spin,odf,numIter,varargin)
% numerically solve the continuity equation with a given spin tensor
%
% Syntax
%
%   odf_n = doEulerStep(spin,odf_0,numIter)
%
%   ori_n = doEulerStep(spin,ori_0,numIter)
%
% Input
%  spin    - @SO3VectorField, orientation dependent spin tensor
%  odf_0   - @SO3Fun, initial ODF
%  ori_0   - @orientation, initial list of orientations
%  numIter - number of iterations
%
% Output
%  odf_n   - @SO3Fun, ODF after numIter iteration steps
%  ori_n   - @orientation, orientations after numIter iteration steps
%
% See also
% SingleSlipModel, Taylormodel, SO3Fun/div, strainTensor/calcTaylor
%

if nargin == 2 || isempty(numIter)
  numIter = 1; 
end

% TODO: Routine to decide which one to use dependent on h and spin.

pC = progressCounter(numIter,'caption',"Euler steps: ",varargin{:});
if isa(odf,'orientation')

  for n = 1:numIter
    
    % the local gradient
    if isa(spin,'SO3VectorField')
      tv = spin.eval(odf) ./ numIter;
    else
      tv = spin(odf) ./ numIter;
    end

    % rotate the individual orientations
    % this coincides with the ODF version below
    odf = exp(tv, odf);

    % this coincides with the discrete taylor route
    %odf = odf .* orientation(-tv);

    pC.show(n);

  end

elseif check_option(varargin,'implicit') %by lsqr

  % Adjust tangent space (TODO: Maybe not necessary in new SO3TangentSpace-Code)
  spin.internTangentSpace = sign(spin.internTangentSpace);
  spin.tangentSpace = spin.internTangentSpace;

  % parameter for lsqr
  tol = get_option(varargin, 'tol', 1e-3);
  maxit = get_option(varargin, 'maxit', 100);
  
  % Transform to harmonic data
  bw = get_option(varargin,'bandwidth',32);
  odf = SO3FunHarmonic(odf,'bandwidth',bw);
  odf.bandwidth = bw;
  if isa(spin,'SO3VectorField')
    spin = SO3VectorFieldHarmonic(spin,'bandwidth',bw); % TODO: Maybe do not transform
    spin.bandwidth = bw;
  end

  for n=1:numIter
    % implicit Euler step by lsqr
    [fhat,~] = lsqr( @(x, transp_flag) afun(transp_flag, x, 1/numIter,spin,bw,odf.CS,odf.SS),odf.fhat, tol, maxit);
    odf.fhat = fhat;
    pC.show(n);
  end

elseif check_option(varargin,'implicit_fixPoint') % by fix point iteration

  % parameter 
  tol = get_option(varargin, 'tol', 1e-3);
  maxit = get_option(varargin, 'maxit', 20);

  for n=1:numIter
    % implicit Euler step by fixpoint iteration
    f_old = odf;
    Error = inf;
    iter = 1;
    while (Error(end)>tol && iter<maxit) 
      f_new = odf - div(f_old .* spin) / numIter;
      Error(iter+1) = norm(f_old-f_new);
      if Error(iter+1)>Error(iter) % break if the Error increases
        break
      end
      f_old = f_new;
      iter = iter + 1;
    end
    odf = f_old;
    pC.show(n);
  end


else

  for n = 1:numIter
    % transport equation (explicit Euler step)
    odf = odf - div(odf .* spin) ./ numIter;
    pC.show(n);
  end

end


end



function y = afun(transp_flag, x, h,spin,bw,cs,ss, varargin)

if strcmp(transp_flag, 'notransp')

  x = SO3FunHarmonic(x,cs,ss);
  D = div( x .* spin); % TODO: Compute product by setting bandwidth. Maybe prevent SO3FunHarmonic-Trafo of spin
  y = x + h * D;
  y.bandwidth = bw;
  y = y.fhat;

elseif strcmp(transp_flag, 'transp')

  x = SO3FunHarmonic(x,cs,ss);
  G = grad(x,spin.tangentSpace);
  H = dot(G,spin); % TODO: Set bandwidth in computation of dot manually. Maybe prevent SO3FunHarmonic-Trafo of spin
  y = x - h * H;
  y.bandwidth = bw;
  y = y.fhat;

end

end