function [TVoigt, TReuss, THill] = calcTensor(ebsd,varargin)
% compute the average tensor for an EBSD data set
%
% Syntax
%   % applies a tensor on a given phase
%   [TVoigt, TReuss, THill] = calcTensor(ebsd('phase2'),T_phase2)
%
%   % applies each tensor given in order of input to each phase
%   [TVoigt, TReuss, THill] = calcTensor(ebsd,T_phase1,T_phase2,...) 
%
%   % returns the specified  tensor
%   THill = calcTensor(ebsd,T_phase1,T_phase2,'Hill') 
%
%   % geometric mean instead of arithmetric one
%   TGeom = calcTensor(ebsd,T_phase1,T_phase2,'geometricMean') 
%
% Input
%  ebsd     - @EBSD
%  T_phaseN - @tensor for the N--th phase
%
% Output
%  T    - @tensor
%
% Options
%  Voigt - Voigt mean
%  Reuss - Reuss mean
%  Hill  - Hill mean
%  geometricMean  -geometric mean
%
% See also
%

% extract tensors and remove them from varargin
Tind = cellfun(@(t) isa(t,'tensor'),varargin);
T = varargin(Tind);
varargin(Tind) = [];

% initialize avarage tensors
TVoigt = T{1};
TVoigt.CS = specimenSymmetry;
TReuss = inv(TVoigt);
TVoigt.M = zeros(repmat(3,1,TVoigt.rank));
TReuss.M = zeros(repmat(3,1,TReuss.rank));

% get phases and populate tensors
phases = unique(ebsd.phaseId)';
if numel(T) < max(phases)
  if numel(T) == numel(phases)
    TT(phases) = T;
    T = TT;
  elseif numel(T) == 1
    T = repmat(T,numel(phases),1);
  else
    error('There are more phases then tensors');
  end
end

% cycle through phases and tensors
for p = phases

  % extract orientations
  ebsd_p = subSet(ebsd,ebsd.phaseId == p);
  ori = ebsd_p.orientations;
    
  rotT = rotate(T{p},ori);
  rotInvT = rotate(inv(T{p}),ori);
  
  % for the geometric mean take the matrix logarithm before summing up
  if check_option(varargin,'geometricMean')
    
    rotT = logm(rotT);
    rotInvT = logm(rotInvT);
    
  end
        
  % take the mean of the rotated tensors
  TVoigt = sum(rotT ./ length(ebsd)) + TVoigt;

  % take the mean of the rotated tensors
  TReuss = sum(rotInvT ./ length(ebsd)) + TReuss;
  
end

% for Reuss tensor invert back
TReuss = inv(TReuss);

% for the geometric mean take matrix exponential to go back
if check_option(varargin,'geometricMean')
  TVoigt = expm(TVoigt);
  TReuss = expm(TReuss);
end

% Hill is simply the mean of Voigt and Reuss averages
THill = 0.5*(TReuss + TVoigt);

% if type is specified only return this type
if check_option(varargin,'Reuss'), TVoigt = TReuss;end
if check_option(varargin,'Hill'), TVoigt = THill;end
