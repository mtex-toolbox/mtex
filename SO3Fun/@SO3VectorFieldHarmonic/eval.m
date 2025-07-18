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


% check whether the hidden symmetries match the symmetries of the
% underlying SO3Fun dependent on the tangent space representation
check_symmetry(SO3VF)


% change evaluation method for quadratureSO3Grid
if isa(rot,'quadratureSO3Grid') && strcmp(rot.scheme,'ClenshawCurtis')
  
  % make sure that symmetries of quadratureSO3Grid match to SO3VectorField-symmetries
  if SO3VF.CS ~= rot.CS || SO3VF.SS ~= rot.SS
    warning('During evaluation: The symmetries of the quadratureSO3Grid do not match to the symmetries of the SO3VectorField.')
  end
  
  if SO3VF.SO3F.CS == rot.CS || SO3VF.SO3F.SS == rot.SS % no symmetries or identic tangent spaces
    xyz = evalEquispacedFFT(SO3VF.SO3F,rot,varargin{:});
  else
    % xyz = eval(SO3VF.SO3F,rot(:),varargin{:});
   
    % forget symmetries to use fft:
    % If the inner tangential space does not match that of the vector field, 
    % we have different symmetries in the internal SO3Fun than in the 
    % vector field. One idea for the evaluation is to ignore the symmetries 
    % and evaluate them with FFT on the full quadrature grid.
    % Subsequently, the surplus evaluations could be omitted, as we only 
    % have to evaluate on a sub-grid.
    fullG = quadratureSO3Grid(rot,crystalSymmetry,specimenSymmetry);
    fun = SO3VF.SO3F; fun.CS = crystalSymmetry; fun.SS = specimenSymmetry;
    xyz = evalEquispacedFFT(fun,fullG,varargin{:});
    xyz = reshape(xyz,[size(fullG.fullGrid) 3]);
    s = size(rot.fullGrid);
    xyz = xyz(1:s(1),1:s(2),1:s(3),:);
    xyz = reshape(xyz,[],3);
    xyz = xyz(rot.ifullGrid,:);
    fullG = fullG.fullGrid(1:s(1),1:s(2),1:s(3));
    rot = fullG(rot.ifullGrid);
        
  end

else
  xyz = SO3VF.SO3F.eval(rot,varargin{:});
end

% generate tangent space vector
f = SO3TangentVector(xyz.',rot(:),SO3VF.internTangentSpace,SO3VF.hiddenCS,SO3VF.hiddenSS);
f = reshape(f,size(rot));

% Maybe change tangent space
tS = SO3TangentSpace.extract(varargin{:},SO3VF.tangentSpace);
f = transformTangentSpace(f,tS);

end
