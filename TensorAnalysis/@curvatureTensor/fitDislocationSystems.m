function [rho,factor] = fitDislocationSystems(kappa,dS,varargin)
% fit dislocation systems to a curvature tensor
%
% Formulae are taken from the paper:
%
% Pantleon, Resolving the geometrically necessary dislocation content by
% conventional electron backscattering diffraction, Scripta Materialia,
% 2008
%
% Syntax
%
%   rho = fitDislocationSystems(kappa,dS)
%
%   % compute complete curvature tensor
%   kappa = dS.dislocationTensor * rho;
%
% Input
%  kappa - (incomplete) @curvatureTensor
%  dS    - list of @dislocationSystem 
%
% Output
%  rho    - dislocation densities 
%  factor - converting rho into units of 1/m^2
%

% ensure we consider also negative line vector
dS = [dS,-dS];

% compute the curvatures corresponding to the dislocations
dT = curvature(dS.tensor);

% coefficients rho_1,...,rho_n >= 0 such that u_1 rho_1 + ... + u_n rho_n is
% minimal and rho_1 dT_1(:,1:2) + ... + rho_n dT_n(:,1:2) = kappa(:,1:2)
A = reshape(permute(dT.M(:,1:2,:,:),[1 2 4 3]),6,size(dS,2),[]);
y = reshape(kappa.M(:,1:2,:),6,[]);
rho = linprogCentre(dS.u.',A,y).';

rho = rho(:,1:size(rho,2)/2) - rho(:,size(rho,2)/2+1:end);

% compute the scaling of rho with respect to 1/m^2
if nargout == 2
  try
    factor = 1./getUnitScale(dT.opt.unit) ./ ...
      getUnitScale(strrep(kappa.opt.unit,'1/',''));
  catch
    error('No units found in the curvature tensor');
  end
end
