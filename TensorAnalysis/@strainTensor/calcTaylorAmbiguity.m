function [M,b,spin] = calcTaylorAmbiguity(eps,sS,varargin)
% Compute the Taylor factor and the strain-dependent orientation gradient
% while accounting for the Taylor ambiguity.
%
% To this end, we compute the simplex (convex polyhedron) of all admissible
% solutions of the Taylor model. Depending on the input strain tensor eps,
% this yields an orientation-dependent scalar function M and vector field W,
% corresponding to the Taylor factor and the spin tensor, respectively.
%
% The flag 'mean' returns the mean spin tensor over the vertices of the
% solution simplex.
%
% The flag 'inverseDistance' returns a weighted mean (with respect to the
% Taylor factor), while the tolerance parameter tol allows all vertices to
% be considered optimal if they lead to a Taylor factor not exceeding
% (1+tol)*M.
%
% If no flag is set, then we obtain for each point a cell array containing
% the vertices of the solution simplex.
%
% Syntax
%   [M,b,W] = calcTaylorAmbiguity(epsC,sS)
%   [MFun,~,spinFun] = calcTaylorAmbiguity(eps,sS)
%   [MFun,~,spinFun] = calcTaylorAmbiguity(eps,sS,'inverseDistance',0.01)
%   [MFun,~,spinFun] = calcTaylorAmbiguity(eps,sS,'mean')
%   b = calcTaylorAmbiguity(epsC,sS,W)          % compute burgers vector dependent on the resulting strain 
%
%
% Input
%  epsC - @strainTensor list in crystal coordinates
%  eps - @strainTensor list in crystal coordinates
%  sS  - @slipSystem list in crystal coordinates
%
% Output
%  Mfun    - @SO3FunHarmonic (orientation dependent Taylor factor)
%  spinFun - @SO3VectorFieldHarmonic
%  M - taylor factor
%  b - vector of slip rates for all slip systems 
%  W - @spinTensor
%
% Options
%  'mean'            - return the mean spin tensor over all vertices of the solution simplex
%  'inverseDistance' - return a Taylor-factor–weighted mean spin tensor
%  'min2norm'        - choose the edge with minimal Euclidean-norm
%  'regularize'
%
% Example
%   
%   % define 10 percent strain
%   eps = 0.1 * strainTensor(diag([1 -0.75 -0.25]))
%
%   % define a crystal orientation
%   cs = crystalSymmetry('cubic')
%   ori = orientation.byEuler(0,30*degree,15*degree,cs)
%
%   % define a slip system
%   sS = slipSystem.fcc(cs)
%
%   % compute the Taylor factor w.r.t. the given orientation
%   [M,b,W] = calcTaylorAmbiguity(inv(ori)*eps,sS.symmetrise)
%
%   % update orientation
%   oriNew = ori .* orientation(-W)
%
%
%   % compute the Taylor factor and spin Tensor w.r.t. any orientation
%   [Mfun,~,Spinfun] = calcTaylorAmbiguity(eps,sS.symmetrise)
%

W = getClass(varargin,{'spinTensor','SO3VectorField'});
if ~isempty(W)
  M = calcTaylorBV(eps,sS,varargin{:});
  return
end

if check_option(varargin,'regularize')
  [M,b,spin] = calcTaylor(eps,sS,varargin{:});
  return
end

if sS.CS.Laue ~= eps.CS.Laue

  if length(eps)>1
    error('Not implemented yet. Use the older ''calcTaylor'' method.')
  end

  epsLocal = strainTensor(eps.M(:,:,1));

  % Compute Taylor factor
  M = SO3FunHandle(@(rot) calcTaylorAll(inv(orientation(rot,sS.CS,eps.CS))*epsLocal,sS),sS.CS,eps.CS);

  % Compute b
  if check_option(varargin,{'mean','inverseDistance','min2norm'})
    b = SO3FunHandle(@(rot) calcTaylorB(rot,epsLocal,sS,varargin{:}),sS.CS,eps.CS);
    spin = SO3VectorFieldHandle(@(rot) calcTaylorSpin(rot,epsLocal,sS,varargin{:}),SO3TangentSpace.leftVector,sS.CS,eps.CS);
    spin.tangentSpace  = SO3TangentSpace.leftSpinTensor;
  else
    b = @(rot) calcTaylorB(rot,epsLocal,sS,varargin{:});
    spin = @(rot) calcTaylorSpin(rot,epsLocal,sS,varargin{:});
  end
  
  return
end

if nargout<=1
  M = calcTaylorAll(eps,sS,varargin{:});
elseif nargout==2
  [M,b,~] = calcTaylorAll(eps,sS,varargin{:});
else
  [M,b,spin] = calcTaylorAll(eps,sS,varargin{:});
end


end

function b = calcTaylorB(rot,eps,sS,varargin)
  ori = orientation(rot,sS.CS,eps.CS);
  [~,b] = calcTaylorAll(inv(ori)*eps,sS,varargin{:});
end

function Out = calcTaylorSpin(rot,eps,sS,varargin)
  ori = orientation(rot,sS.CS,eps.CS);
  [~,~,spin] = calcTaylorAll(inv(ori)*eps,sS,varargin{:});
  if check_option(varargin,{'mean','inverseDistance','min2norm'})
    v = vector3d(ori(:) .* spin);
    Out = v.xyz;
  else
    ori = arrayfun(@(i) ori(i) , 1:length(ori), 'UniformOutput', false);
    Out = cellfun(@(s,o) o.*s ,spin,ori,'UniformOutput',false);
  end
end
