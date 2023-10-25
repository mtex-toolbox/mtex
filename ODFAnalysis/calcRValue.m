function [minMtheta, R, Mtheta, rhoTheta]  = calcRValue(ori,sS,varargin)
% plastic anisotropy ratio from ODF or orientations
%
% Description
% This function computes the minimum Taylor factor (M) and the plastic 
% anisotropy ratio (R-value) as a function of the angle theta to the tensile 
% direction.
%
% Syntax:
%  [minMtheta, R, Mtheta, rhoTheta] = calcRValue(ori,sS,tA,theta)
%
% Input:
%  ori - @orientation
%  sS  - @slipSystem
%  tA  - @vector3d - tensile axis
%  theta - angle to the tensile direction, default 0,5,10,..,90 degree
%
% Output:
%  minMtheta - minimum Taylor factor
%  R         - plastic anisotropy ratio (R-value) at minimum Taylor factor
%  Mtheta    - Taylor factor
%  rhoTheta  - plastic strain (rho)
%
% Options:
%  silent - supress output
%
% Authors:
% * Dr. Azdiar Gazder, 2023
% * Dr. Manasij Kumar Yadava, 2023
%

% I do not realy understand the warning. We have two directions involved
% (1) - the axis we perform the rotation around, default - z
% (2) - the axis we use to define the tensial strain, default - x
% Questions: 
% (a) can we simply call axis (2) the tensile axis?
% (b) is the choice of (1) crucial or does it only need to be perpendicular
% to (2)?
% I would like to make this optional inputs to the function

warning(sprintf(['\ncalcRValue assumes the orientation data of the sheet is in following format:',...
    '\nRD || tensile direction = horizontal; TD = vertical; ND = out-of-plane']));

sS = sS.ensureSymmetrised;

% get tensial axis and theta
theta = linspace(0,90*degree,19);
tA = xvector;

if nargin >=3 && isa(varargin{1},'vector3d')
  tA = varargin{1};

  % get the theta angle
  if nargin >=4 && isa(varargin{2},'double'), theta = varargin{2}; end
end

% the rotation axis
rA = zvector;

% rotate the orientations incrementally about the pre-defined tensile axis
% here RD || tensile axis || map horizontal
% oriRot = ori x rot_theta
oriRot = (rotation.byAxisAngle(rA,theta) * ori).';

% strain tensor in the specimen reference frame (sRF)
% it is not axi-symmetric since rho values are changing
rho = linspace(0,1,11); % 0-100 % uniaxial tension 
eps_sRF = velocityGradientTensor.uniaxial(tA,rho);

% transform the strain tensor into crystal reference frame (xRF)
% ori x theta x strain
strainTensor_xRF = inv(oriRot) * eps_sRF; %#ok<MINV>
                                                  
% the Taylor factor for all strains and all orientations
% Taylor factor (M) = ori x theta x strain (or rho) range
[M,~,~] = calcTaylor(strainTensor_xRF,sS);%,'silent');
M = reshape(M,length(ori),length(theta),length(rho));

% take the mean along ori -> Mtheta = strain x theta
Mtheta = squeeze(mean(M,1)).'; 

% Find the minimum Taylor factor along the strain (or rho) range
[minMtheta,idx] = min(Mtheta,[],1); 

% the corresponding R and rhoTheta values
Rrange = rho ./ (1 - rho);
R = Rrange(idx);
rhoTheta = rho(idx);

if ~check_option(varargin,'silent')
  disp('---')
  disp(['M at 0°  to RD = ',num2str(minMtheta(1))]);
  disp(['M at 45° to RD = ',num2str(minMtheta(10))]);
  disp(['M at 90° to RD = ',num2str(minMtheta(19))]);
  disp('---')
  disp(['R at 0°  to RD = ',num2str(R(1))]);
  disp(['R at 45° to RD = ',num2str(R(10))]);
  disp(['R at 90° to RD = ',num2str(R(19))]);
  disp('---')
  Rbar = 0.5 * (R(1) + R(19) - 2*R(10));
  disp(['Rbar = ',num2str(Rbar)]);
  disp('---')
end
end
