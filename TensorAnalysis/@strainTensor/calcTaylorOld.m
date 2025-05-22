function [M,b,spin] = calcTaylorOld(eps,sS,varargin)
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


% Compute the Taylor factor and strain dependent gradient independent of 
% the orientation, i.e. SO3FunHarmonic and SO3VectorFieldHarmonic
if sS.CS.Laue ~= eps.CS.Laue
  bw = get_option(varargin,'bandwidth',32);
  numOut = nargout;
  for k = 1:length(eps)
    progress(k,length(eps));
    epsLocal = strainTensor(eps.M(:,:,k));
    F = SO3FunHandle(@(rot) calcTaylorFun(rot,epsLocal,sS,numOut,varargin{:}),sS.CS,eps.CS);
    
    % Use Gauss-Legendre quadrature, since the evaluation process is very expansive
    SO3F = SO3FunHarmonic(F,'bandwidth',bw,'GaussLegendre','regularization',0);
    M(k) = SO3F(1); %#ok<AGROW>
    if nargout>1
      b = [];
      spin(k) = SO3VectorFieldHarmonic(SO3F(2:4),SO3TangentSpace.leftVector); %#ok<AGROW>
      % to be comparable set output to rightspintensor      
      spin.tangentSpace  = SO3TangentSpace.rightSpinTensor;
    end
  end
  
  % for some reason we need some smoothing of the vector field
  if nargout>1
    psi = SO3DeLaValleePoussinKernel('halfwidth',5*degree);
    spin.SO3F = spin.SO3F.conv(psi);
  end
  return
end

if nargout<=1
  M = calcTaylor1(eps,sS,varargin{:});
elseif nargout==2
  [M,b,~] = calcTaylor1(eps,sS,varargin{:});
else
  [M,b,spin] = calcTaylor1(eps,sS,varargin{:});
end

end

function Out = calcTaylorFun(rot,eps,sS,numOut,varargin)
  ori = orientation(rot,sS.CS,eps.CS);
  [Taylor,~,spin] = calcTaylor1(inv(ori)*eps,sS,varargin{:});
  Out(:,1) = Taylor(:);
  if numOut>1
    v = ori .* vector3d(spin);
    Out(:,2:4) = v.xyz;
  end
end


























function checkHex %#ok<DEFNU>
cs = crystalSymmetry.load('Mg-Magnesium.cif');
cs = cs.properGroup;

sScold = [slipSystem.basal(cs,1),...
  slipSystem.prismatic2A(cs,66),...
  slipSystem.pyramidalCA(cs,80),...
  slipSystem.twinC1(cs,100)];

% consider all symmetrically equivalent slip systems
sScold = sScold.symmetrise;

epsCold = 0.3 * strainTensor(diag([1 -0.6 -0.4]));

[~,~,W] = calcTaylor(epsCold,sScold);

%%

ori0 = orientation.rand(cs);
ori0 = ori0.symmetrise;

[~,~,Wori] = calcTaylor(inv(ori0)*epsCold,sScold);
% this should give all the same vectors
ori0 .* vector3d(Wori) %#ok<NOPRT>

ori0 .* vector3d(W.eval(ori0)) %#ok<NOPRT>

end


