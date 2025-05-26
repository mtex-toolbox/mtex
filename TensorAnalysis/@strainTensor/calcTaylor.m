function [M,b,spin,NoE] = calcTaylor(eps,sS,varargin)
% compute Taylor factor and strain dependent orientation gradient
%
% Syntax
%   [MFun,~,spinFun] = calcTaylor(eps,sS,'bandwidth',32)
%   [M,b,W] = calcTaylor(eps,sS)
%
% Input
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
%   [M,b,W] = calcTaylor(inv(ori)*eps,sS.symmetrise)
%
%   % update orientation
%   oriNew = ori .* orientation(-W)
%
%
%   % compute the Taylor factor and spin Tensor w.r.t. any orientation
%   [M,~,W] = calcTaylor(eps,sS.symmetrise)
%

if sS.CS.Laue ~= eps.CS.Laue

  if length(eps)>1
    error('Not implemented yet. Use the older ''calcTaylorOld'' method.')
  end

  % TODO: For efficient computation of SO3FunHarmonics look into TaylorOld.

  epsLocal = strainTensor(eps.M(:,:,1));

  % Compute Taylor factor
  M = SO3FunHandle(@(rot) calcTaylorAll(inv(orientation(rot,sS.CS,eps.CS))*epsLocal,sS),sS.CS,eps.CS);

  % Compute b
  if check_option(varargin,{'mean','inverseDistance'})
    b = SO3FunHandle(@(rot) calcTaylorB(rot,epsLocal,sS,varargin{:}),sS.CS,eps.CS);
    spin = SO3VectorFieldHandle(@(rot) calcTaylorSpin(rot,epsLocal,sS,varargin{:}),SO3TangentSpace.leftVector,sS.CS,eps.CS);
    spin.tangentSpace  = SO3TangentSpace.leftSpinTensor;
  else
    b = @(rot) calcTaylorB(rot,epsLocal,sS,varargin{:});
    spin = @(rot) calcTaylorSpin(rot,epsLocal,sS,varargin{:});
  end
  
  % Compute Number of Edges
  NoE = SO3FunHandle(@(rot) calcTaylorNum(rot,epsLocal,sS,varargin{:}),sS.CS,eps.CS);

  return
end

NoE=[];
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
  if check_option(varargin,{'mean','inverseDistance'})
    v = vector3d(ori(:) .* spin);
    Out = v.xyz;
  else
    ori = arrayfun(@(i) ori(i) , 1:length(ori), 'UniformOutput', false);
    Out = cellfun(@(s,o) o.*s ,spin,ori,'UniformOutput',false);
  end
end

function Out = calcTaylorNum(rot,eps,sS,varargin)
  ori = orientation(rot,sS.CS,eps.CS);
  [~,Out] = calcTaylorAll(inv(ori)*eps,sS,varargin{:},'numberOfEdges');
end













