function [R, M, minM]  = calcLankford(ori,sS,varargin)
% Lankford coefficient or R-value from orientations or ODF
%
% Description
% The R-value, is the ratio of the true width strain to the true thickness
% strain at a particular value of length strain.
%
% The normal anisotropy ratio (Rbar, or Ravg, or rm) defines the ability of
% the metal to deform in the thickness direction relative to deformation in
% the plane of the sheet. For Rbar values >= 1, the sheet metal resists
% thinning, improves cup drawing, hole expansion, and other forming modes
% where metal thinning is detrimental. For Rbar < 1, thinning becomes the
% preferential metal flow direction, increasing the risk of failure in
% drawing operations.
%
% A related parameter is the planar anisotropy parameter (deltaR) which is
% an indicator of the ability of a material to demonstrate non-earing
% behavior. A deltaR value = 0 is ideal for can-making or deep drawing of
% cylinders, as this indicates equal metal flow in all directions; thus
% eliminating the need to trim ears during subsequent processing.
%
% Syntax:
%   [R, minM, M] = calcRValue(ori,sS,theta,RD,ND)
%
% Input:
%  ori - @orientation
%  sS  - @slipSystem
%  theta - angle of the tensial direction with respect to RD, default 0,5,10,..,90 degree
%  RD  - @vector3d - rolling direction, default - x - used as reference tension direction
%  ND  - @vector3d - normal direction, default - z
%  
% Output:
%  R    - plastic anisotropy ratio (R-value) with minimum Taylor factor as a function of theta
%  M    - Taylor factor as a function of theta and R
%  minM - minimum Taylor factor as a function of theta
%
% Options:
%  verbose - show summary
%  weights - @double, containing texture information
%
% Authors:
% * Dr. Azdiar Gazder, 2023
% * Dr. Manasij Kumar Yadava, 2023
%

sS = sS.ensureSymmetrised;

% get tensile axis and theta
theta = linspace(0,90*degree,19);
RD = xvector; % default RD
ND = zvector; % default ND
if nargin >=3 && isa(varargin{1},'double'), theta = varargin{1}; end
if nargin >=4 && isa(varargin{2},'vector3d'), RD = varargin{2}; end
if nargin >=5 && isa(varargin{3},'vector3d'), ND = varargin{2}; end

% strain tensor in the specimen reference frame (sRF)
% it is not axi-symmetric since rho values are changing
% rho = 0 -> only normal direction
% rho = 1 -> only transverse direction
rho = get_option(varargin,'rho',linspace(0,1,11));
TD = cross(RD,ND);
eps =  strainTensor(RD * RD) - rho .* strainTensor(TD*TD) ...
  -(1 - rho) .* strainTensor(ND*ND);
                                                 
if isa(ori,"orientation")

  % rotate the tensile axis within the rolling plane by angle theta
  % eps -> theta x rho
  eps =  rotation.byAxisAngle(ND,-theta) *eps;

  % the Taylor factor for all strains and all orientations
  % Taylor factor M = ori x theta x rho
  M = calcTaylor(inv(ori) * eps,sS);

  % average the Taylor factor over the texture (ori) -> M = theta x rho
  weights = get_option(varargin,'weights',ones(size(ori)));
  weights = weights ./ sum(weights);
  M = weights(:).' * reshape(M,length(ori),[]);
  % tranpose M -> rho x theta
  M = reshape(M,length(theta),length(rho)).';

else

  bw = get_option(varargin,'bandwidth',16);
  odf = SO3FunHarmonic(ori,'bandwidth',bw);
  MFun = calcTaylor(eps,sS,'bandwidth',bw);

  for k = 1:length(theta)
    M(:,k) =  cor(MFun, rotate(odf,rotation.byAxisAngle(ND,theta(k))));
  end

end

% find the minimum Taylor factor along the strain anisotropy
[minM,idx] = min(M,[],1); 

% the corresponding R value
R = rho(idx) ./ (1 - rho(idx));

if check_option(varargin,'verbose')
  disp('---')
  disp(['M at 0°  to tA = ',num2str(minM(theta==0))]);
  disp(['M at 45° to tA = ',num2str(minM(theta==45*degree))]);
  disp(['M at 90° to tA = ',num2str(minM(theta==90*degree))]);
  disp('---')
  disp(['R at 0°  to tA = ',num2str(R(theta==0))]);
  disp(['R at 45° to tA = ',num2str(R(theta==45*degree))]);
  disp(['R at 90° to tA = ',num2str(R(theta==90*degree))]);
  disp('---')
  Rbar = 0.5 * (R(theta==0) + R(theta==90*degree) - 2*R(theta==45*degree));
  disp(['Rbar = ',num2str(Rbar)]);
  disp('---')
end
end
