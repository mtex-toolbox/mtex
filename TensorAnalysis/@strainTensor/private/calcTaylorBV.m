function b = calcTaylorBV(eps,sS,spin,varargin)
% Compute the burgers vector with the Taylor model, if the spin is given.
%
% Syntax
%   b = calcTaylorBurgersV(epsC,sS,spin)
%   B = calcTaylorBurgersV(eps,sS,W)
%
% Input
%  epsC - @strainTensor list in crystal coordinates
%  eps  - @strainTensor list in specimen coordinates
%  sS   - @slipSystem list in crystal coordinates
%  spin - @spinTensor
%  W    - @SO3VectorField (orientation dependent spin tensor)
%
% Output
%  b - vector of slip rates for all slip systems 
%  B - @function_handle
%
 
if sS.CS.Laue ~= eps.CS.Laue

  if length(eps)>1
    error('Not implemented yet. Use the older ''calcTaylor'' method.')
  end

  epsLocal = strainTensor(eps.M(:,:,1));

  % Compute Taylor factor
  b = @(rot) calcTaylorB(rot,epsLocal,sS,spin,varargin{:});
  
  return
end

b = calcTaylorBurgersVector(eps,sS,spin,varargin{:});

end

function b = calcTaylorB(rot,eps,sS,spin,varargin)
  ori = orientation(rot,sS.CS,eps.CS);
  try
    W = spin.eval(ori);
  catch
    W = spin(ori);
  end
  b = calcTaylorBurgersVector(inv(ori)*eps,sS,W,varargin{:});
end
