function [TVoigt, TReuss, THill] = calcTensor(ebsd,varargin)
% compute the average tensor for an EBSD data set
%
%% Syntax
% [TVoigt, TReuss, THill] = calcTensor(ebsd,T_phase1,T_phase2)
% [TVoigt, TReuss, THill] = calcTensor(ebsd,T_phase2,'phase',2)
% THill = calcTensor(ebsd,T_phase1,T_phase2,'Hill')
%
%% Input
%  ebsd     - @EBSD
%  T_phase1 - @tensor for phase 1
%  T_phase1 - @tensor for phase 2
%
%% Output
%  T    - @tensor
%
%% Options
%  voigt - voigt mean
%  reuss - reuss mean
%  hill  - hill mean
%
%% See also
%

% extract tensors and remove them from varargin
Tind = cellfun(@(t) isa(t,'tensor'),varargin);
T = varargin(Tind);
varargin(Tind) = [];

% for Reuss average invert tensor
Tinv = cellfun(@(t) inv(t),T,'uniformOutput',false);

% get phases
phases = get(ebsd,'phase');

% initialize avarage tensors
TVoigt = tensor(zeros(size(T{1})));
TReuss = tensor(zeros(size(T{1})));
sZ = sampleSize(ebsd);

% cycle through phases and tensors
for i = 1:min(length(T),length(ebsd))
  
  % extract orientations and wights
  [SO3,ind] = get(ebsd,'orientations','phase',phases(i));
  weight = get(ebsd(ind),'weight')*sum(sZ(ind))./sum(sZ);

  % take the mean of the rotated tensors times the weight
  TVoigt = TVoigt + sum(weight .* rotate(T{i},SO3));
  
  % take the mean of the rotated tensors times the weight
  TReuss = TReuss + sum(weight .* rotate(Tinv{i},SO3));
    
end

% for Reuss tensor invert back
TReuss = inv(TReuss);

% Hill is simply the mean of Voigt and Reuss averages
THill = 0.5*(TReuss + TVoigt);

% if type is specified only return this type
if check_option(varargin,'Reuss'), TVoigt = TReuss;end
if check_option(varargin,'Hill'), TVoigt = THill;end
