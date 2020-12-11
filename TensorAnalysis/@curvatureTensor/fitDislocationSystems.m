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

% ensure linprog is working
try
  linprog(0,0,0);
catch
  error('Optimization Toolbox not found. The function fitDislocationSystems depends on the Matlab Optimzation Toolbox or, more specifically, on the function linprog.')
end


% ensure we consider also negative line vector
dS = [dS,-dS];

% compute the curvatures corresponding to the dislocations
dT = curvature(dS.tensor);

% options for linprog algorithms
options = optimset('algorithm','interior-point-legacy','Display','off');

rho = nan(size(dS));
for i = 1:length(kappa)

  % try to find coefficients
  % b_1,...,b_n such that b_1 + b_2 + ... b_n is minimal and
  % b_1 dT_1(1:2,:) + b_2 dT_2(1:2,:) + ... + b_n dT_n(1:2,:) = kappa(1:2,:)

  A = reshape(dT.M(:,1:2,i,:),6,[]); % the system of equations
  y = reshape(kappa.M(:,1:2,i),6,1); % the right hand side
  u = dS(i,:).u; % the line energies
  
  % determine coefficients rho with A * rho = y and such that sum |rho_j|
  % is minimal. This is equivalent to the requirement 
  %  rho>=0 and sum(u_jrho_j) -> min 
  % which is the linear programming problem solved below
  try %#ok<TRYNC>
    
    rho(i,:) = linprog(u,[],[],A,y,zeros(size(A,2),1),[],1,options);
 
    progress(i,length(kappa),' fitting: ');

  end
      
end

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
