function [R, minM, M]  = calcRValue(ori,sS,varargin)
% plastic anisotropy ratio, R-value or Lankford coefficient from ODF or orientations
%
% Description
% This function computes the minimum Taylor factor (M) and the plastic
% anisotropy ratio (R-value, Lankford coefficient) as a function of the
% angle theta between the tensile direction and the rolling direction.
%
% Syntax:
%  [R, minM, M] = calcRValue(ori,sS,theta,tA)
%
% Input:
%  ori - @orientation
%  sS  - @slipSystem
%  theta - angle between tA and rD, default 0,5,10,..,90 degree
%  tA  - @vector3d - tensile axis, default x
%  rD  - @vector3d - rolling direction, default z 
%
% Output:
%  R    - plastic anisotropy ratio (R-value) with minimum Taylor factor as a function of theta
%  minM - minimum Taylor factor as a function of theta
%  M    - Taylor factor as a function of theta and R
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
if nargin >=3 && isa(varargin{1},'double'), theta = varargin{1}; end
if nargin >=4 && isa(varargin{2},'vector3d'), tA = varargin{2}; end

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
% Taylor factor (M) = ori x theta x rho
[M,~,~] = calcTaylor(strainTensor_xRF,sS);%,'silent');

% average the Taylor factor over the texture (ori) -> M = rho x theta
weights = get_option(varargin,'weights',ones(size(ori)));
weights = weights ./ sum(weights);
M = weights(:) .* reshape(M,length(ori),[]);
M = reshape(M,length(theta),length(rho)).';

% find the minimum Taylor factor along the strain (rho)
[minM,idx] = min(M,[],1); 

% the corresponding R value
R = rho(idx) ./ (1 - rho(idx));

if ~check_option(varargin,'silent')
  disp('---')
  disp(['M at 0°  to RD = ',num2str(minM(1))]);
  disp(['M at 45° to RD = ',num2str(minM(10))]);
  disp(['M at 90° to RD = ',num2str(minM(19))]);
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
