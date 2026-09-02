function [R, M, minM]  = calcLankford(ori,sS,varargin)
% Lankford coefficient or R-value from orientations or ODF
%
% Description
% The R-value is the ratio of the true width strain to the true thickness
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
% A related parameter is the planar anisotropy parameter (deltaR), a
% conventional indicator of the fourfold earing tendency. A value near zero
% suppresses this contribution but does not imply equal flow at every angle
% or guarantee an ear-free cup.
%
% Syntax:
%   [R, M, minM] = calcLankford(ori,sS,theta,RD,ND)
%
% Input:
%  ori - @orientation
%  sS  - @slipSystem
%  theta - angle of the tensile direction with respect to RD, default 0,5,10,..,90 degrees
%  RD  - @vector3d - rolling direction, default - x - used as reference tension direction
%  ND  - @vector3d - normal direction, default - z
%  
% Output:
%  R    - plastic anisotropy ratio at minimum plastic work for each theta
%  M    - normalized plastic work as a function of theta and rho
%  minM - minimum normalized plastic work as a function of theta
%
% Options:
%  verbose - show summary
%  weights - double, containing texture information
%  rho - width-contraction fraction between 0 and 1
%
% Authors:
% * Dr. Azdiar Gazder, 2023
% * Dr. Manasij Kumar Yadava, 2023
%

% TODO: slipSystem symmetrisation adds both Burgers-vector signs. This makes
% twinning systems reversible pseudo-slip systems; a polarity-aware
% twinning representation is required for physically one-way twinning.
sS = sS.ensureSymmetrised;

% get tensile axis and theta
theta = linspace(0,90*degree,19);
RD = xvector; % default RD
ND = zvector; % default ND
if nargin >=3 && isa(varargin{1},'double'), theta = varargin{1}; end
if nargin >=4 && isa(varargin{2},'vector3d'), RD = varargin{2}; end
if nargin >=5 && isa(varargin{3},'vector3d'), ND = varargin{3}; end

RD = normalize(RD);
ND = normalize(ND);
if ~isPerp(RD,ND)
  error('MTEX:calcLankford:invalidSheetDirections', ...
    'RD and ND must be orthogonal sheet directions.');
end
theta = theta(:).';

% strain tensor in the specimen reference frame (sRF)
% it is not axi-symmetric since rho values are changing
% rho = 0 -> only normal direction
% rho = 1 -> only transverse direction
rho = get_option(varargin,'rho',linspace(0,1,11));
rho = rho(:).';
TD = cross(RD,ND);
eps =  strainTensor(RD * RD) - rho .* strainTensor(TD*TD) ...
  -(1 - rho) .* strainTensor(ND*ND);
                                                 
if isa(ori,"orientation")

  % rotate the tensile axis within the rolling plane by angle theta
  % eps -> theta × rho
  eps =  rotation.byAxisAngle(ND,-theta) *eps;

  % normalized plastic work for all strains and all orientations
  % M = ori × theta × rho
  M = calcTaylor(inv(ori) * eps,sS,'plasticWork'); %#ok<MINV>

  % average the plastic work over the texture (ori) -> M = theta × rho
  weights = get_option(varargin,'weights',ones(size(ori)));
  weights = weights ./ sum(weights(:));
  M = weights(:).' * reshape(M,numel(ori),[]);
  % transpose M -> rho × theta
  M = reshape(M,length(theta),length(rho)).';

else

  bw = get_option(varargin,'bandwidth',16);
  odf = SO3FunHarmonic(ori,'bandwidth',bw);
  MFun = calcTaylor(eps,sS,'plasticWork','bandwidth',bw);

  M = zeros(length(rho),length(theta));
  for k = 1:length(theta)
    M(:,k) =  cor(MFun, rotate(odf,rotation.byAxisAngle(ND,theta(k))));
  end

end

% find the minimum plastic work along the strain anisotropy
[minM,idx] = min(M,[],1); 

% the corresponding R value
R = rho(idx) ./ (1 - rho(idx));

if check_option(varargin,'verbose')
  id0 = find(isnull(theta),1);
  id45 = find(isnull(theta-45*degree),1);
  id90 = find(isnull(theta-90*degree),1);
  if ~isempty(id0) && ~isempty(id45) && ~isempty(id90)
    disp('---')
    disp(['minimum work at 0°  to tA = ',num2str(minM(id0))]);
    disp(['minimum work at 45° to tA = ',num2str(minM(id45))]);
    disp(['minimum work at 90° to tA = ',num2str(minM(id90))]);
    disp('---')
    disp(['R at 0°  to tA = ',num2str(R(id0))]);
    disp(['R at 45° to tA = ',num2str(R(id45))]);
    disp(['R at 90° to tA = ',num2str(R(id90))]);
    disp('---')
    Rbar = 0.25 * (R(id0) + R(id90) + 2*R(id45));
    deltaR = 0.5 * (R(id0) + R(id90) - 2*R(id45));
    disp(['Rbar = ',num2str(Rbar)]);
    disp(['deltaR = ',num2str(deltaR)]);
    disp('---')
  else
    warning('MTEX:calcLankford:missingSummaryAngles', ...
      'The verbose summary requires theta to contain 0, 45, and 90 degrees.');
  end
end
end
