function f = eval(SO3VF,rot,varargin)
% evaluate the SO3VectorFieldHarmonic in rotations
% 
% Syntax
%   f = eval(SO3VF,rot)         % left tangent vector
%
% Input
%  rot - @rotation
%
% Output
%  f - @vector3d
%
% Options
%  bandwidth - cut bandwidth of the harmonic series in evaluation process
%
% Flags
%  nfsoft - use Nonequispace Fast Fourier Transform of the NFFT3 Toolbox (expensive precomputations)
%  noNFFT - do direct evaluation of the harmonic series for every orientation (Works for very high bandwidth if the nfft runs out of memory, but gets expensive for many orientations. Hence number of orientations should be less than 100)
%
% See also
%  SO3FunHarmonic/eval SO3FunHarmonic/evalNFSOFT SO3FunHarmonic/evalEquispacedFFT

% if isa(rot,'orientation')
%   ensureCompatibleSymmetries(SO3VF,rot)
% end

% change evaluation method for quadratureSO3Grid
if isa(rot,'quadratureSO3Grid') && strcmp(rot.scheme,'ClenshawCurtis')
  xyz = evalEquispacedFFT(SO3VF.SO3F,rot,varargin{:});
else
  xyz = SO3VF.SO3F.eval(rot,varargin{:});
end

% generate tangent space vector
f = SO3TangentVector(xyz.',rot(:),SO3VF.internTangentSpace);
f = reshape(f,size(rot));

% Maybe change tangent space
tS = SO3TangentSpace.extract(varargin{:},SO3VF.tangentSpace);
f = transformTangentSpace(f,tS);

end
