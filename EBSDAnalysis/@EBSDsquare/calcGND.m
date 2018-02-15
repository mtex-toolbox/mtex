function [gnd,rho] = calcGND(ebsd,varargin)
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
dS = getClass(varargin,'dislocationSystem');

% if so - compute the corresponding deformation tensor
if ~isempty(dS)
  dS.b = [dS.b,dS.b];
  dS.l = [dS.l,-dS.l];
  CRSS = [dS.CRSS(:);dS.CRSS(:)]; % what is the correct name here?
  dT = dS.dislocationTensor;
  dT = dT - 0.5 * diag(trace(dT));
  
  options = optimset('algorithm','interior-point','Display','off',...
                       'TolX',10^-12,'TolFun',10^-12); 
end
  
% compute the gradients
ori = ebsd.orientations;
gX = ebsd.gradientX(:);
gY = ebsd.gradientY(:);

% 
delta = get_option(varargin,'threshold',5*degree);
gX(norm(gX)>delta) = NaN;
gY(norm(gX)>delta) = NaN;

gX = double(gX);
gY = double(gY);

% initialize an empty matrix for the dislocation tensor
kappa = zeros(3,3);

% initalize the ouput
gnd = nan(size(ebsd));

% compute the GND
for i = 1:length(ebsd)

  % the first two columns of the curvature tensor are just
  % the texture gradients
  kappa(1,:) = gX(i,:);
  kappa(2,:) = gY(i,:);
 
      
  % if slip systems are specified try to find coefficients
  % b_1,...,b_n such that b_1 + b_2 + ... b_n is minimal and
  % b_1 dT_1(1:2,:) + b_2 dT_2(1:2,:) + ... + b_n dT_n(1:2,:) = kappa(1:2,:)
  if ~isempty(dS) && ~isnan(ori(i))
    
    % rotate the dislocation tensor into specimen coordinates
    dT_specimen = rotate(dT,ori(i));
    A = reshape(matrix(dT_specimen),9,[]);
    
    % determine coefficients rho with A * rho = y and such that sum |rho_j|
    % is minimal. This is equivalent to the requirement rho>=0 and 1*rho ->
    % min which is the linear programming problem solved below
    try %#ok<TRYNC>
    
      rho = linprog(CRSS,[],[],A(1:6,:),kappa(1:6)',...
        zeros(size(A,2),1),[],1,options);

    end
    kappa = dT * rho;
  end
    
  alpha = kappa - trace(kappa)*eye(3);
  
  gnd(i) = norm(alpha,2);
  
end
