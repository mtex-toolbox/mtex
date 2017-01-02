function gnd = calcGND(ebsd,varargin)
% compute the geometrically necessary dislocation
%
% Formulae are taken from the paper:
%
% Pantleon, Resolving the geometrically necessary dislocation content by
% conventional electron backscattering diffraction, Scripta Materialia,
% 2008
%
% Syntax
%   gnd = calcGND(ebsd)
%   gnd = calcGND(ebsd,sS)
%
% Input
%  ebsd - @EBSDSquare
%  sS   - @slipSystem 
%
% Output

% maybe slip systems are given
sS = getClass(varargin,'slipSystem');

% is so - compute the corresponding deformation tensor
if ~isempty(sS)
  CRSS = sS.CRSS(:); % critical resolved shear stress
  dT = sS.deformationTensor; % versetungstesnor - Schraubung + stufe
  % if the symmetric part is needed take dT.sym
  A = reshape(matrix(dT),9,[]);
  A = A([1,2,3,5,6],:);

  options = optimoptions('linprog','Algorithm','interior-point','Display','none');
end

% compute the gradients
gX = double(ebsd.gradientX(:));
gY = double(ebsd.gradientY(:));

% initialize an empty matrix for the dislocation tensor
kappa = zeros(3,3);

% initalize the ouput
gnd = nan(size(ebsd));

% compute the GND
for i = 1:length(ebsd)

  % the first two columns of the dislocation tensor are just
  % the texture gradients
  kappa(1,:) = gX(i,:);
  kappa(2,:) = gY(i,:);
 
      
  % if slip systems are specified try to find coefficients
  % b_1,...,b_n such that b_1 + b_2 + ... b_n is minimal and
  % b_1 dT_1(1:2,:) + b_2 dT_2(1:2,:) + ... + b_n dT_n(1:2,:) = kappa(1:2,:)
  if ~isempty(sS)
    % TODO: not yet implemented !!!
    
    % determine coefficients b with A * b = y and such that sum |b_j| is
    % minimal. This is equivalent to the requirement b>=0 and 1*b -> min
    % which is the linear programming problem solved below
    try
      b = linprog(CRSS,[],[],A,kappa(1:2,:),zeros(size(A,2),1),[],[],options);
    end
    kappa = dT * b;
    
    gnd(i) = sum(b);
    continue
    
  end
    
  % as we do not know the texture gradient with respect to the z-direction
  % we have to do something here TODO!!
  alpha = kappa - trace(kappa)*eye(3);
  
  gnd(i) = norm(alpha,2);
  
end
