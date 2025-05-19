function [M,b,spin] = calcTaylor3(eps,sS,varargin)


epsLocal = strainTensor(eps.M(:,:,1));
if check_option(varargin,'new')
  M = SO3FunHandle(@(rot) calcTaylor2(inv(orientation(rot,sS.CS,eps.CS))*epsLocal,sS),sS.CS,eps.CS);
else
  M = SO3FunHandle(@(rot) calcTaylor(inv(orientation(rot,sS.CS,eps.CS))*epsLocal,sS),sS.CS,eps.CS);
end

if nargout==1, return, end

% b = [];
b = SO3FunHandle(@(rot) calcTaylorNum(rot,epsLocal,sS,varargin{:}),sS.CS,eps.CS);


spin = SO3VectorFieldHandle(@(rot) calcTaylorFun(rot,epsLocal,sS,varargin{:}),sS.CS,eps.CS);
% spin = SO3VectorFieldHarmonic(SO3F(2:4),SO3TangentSpace.leftVector);
% to be comparable set output to rightspintensor
% spin.tangentSpace  = SO3TangentSpace.rightSpinTensor;

% for some reason we need some smoothing of the vector field
psi = SO3DeLaValleePoussinKernel('halfwidth',5*degree);
% spin = spin.conv(psi);


end

function Out = calcTaylorFun(rot,eps,sS,varargin)
  ori = orientation(rot,sS.CS,eps.CS);
  if check_option(varargin,'new')
    [~,~,spin] = calcTaylor2(inv(ori)*eps,sS,varargin{:},'mean');
  else
    [~,~,spin] = calcTaylor(inv(ori)*eps,sS,varargin{:});
  end
  v = ori(:) .* vector3d(spin);
  Out = v.xyz;
end

function Out = calcTaylorNum(rot,eps,sS,varargin)
  ori = orientation(rot,sS.CS,eps.CS);
  [~,Out] = calcTaylor2(inv(ori)*eps,sS,varargin{:},'num');

end