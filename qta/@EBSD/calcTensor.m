function [TVoigt, TReuss, THill] = calcTensor(ebsd,varargin)
% compute the average tensor for an EBSD data set
%
%% Syntax
% [TVoigt, TReuss, THill] = calcTensor(ebsd,T_phase1,T_phase2,...) - returns 
%    the Voigt--, Reuss-- and Hill-- @tensor, applies each tensor
%    given in order of input to each phase
%
% [TVoigt, TReuss, THill] = calcTensor(ebsd,T_phase2,'phase',2) - returns the Voigt--, 
%    Reuss-- and Hill-- @tensor, applies a tensor
%    on a given phase
%
% THill = calcTensor(ebsd,T_phase1,T_phase2,'Hill') - returns the specified 
%    @tensor, i.e. 'Hill' in case
%
%% Input
%  ebsd     - @EBSD
%  T_phaseN - @tensor for the N--th phase
%
%% Output
%  T    - @tensor
%
%% Options
%  Voigt - voigt mean
%  Reuss - reuss mean
%  Hill  - hill mean
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
phases = get_option(varargin,'phase',unique(ebsd.phases));

% initialize avarage tensors
TVoigt = tensor(zeros(size(T{1})));
TReuss = tensor(zeros(size(T{1})));

% cycle through phases and tensors
for p = unique(ebsd.phases)'
  
  % extract orientations and wights
  ind = ebsd.phases == p;
  ori = get(ebsd(ind),'orientations');    
  weight = get(ebsd(ind),'weight') * nnz(ind) ./ numel(ebsd);

  % take the mean of the rotated tensors times the weight
  TVoigt = TVoigt + sum(weight .* rotate(T{p},ori));
  
  % take the mean of the rotated tensors times the weight
  TReuss = TReuss + sum(weight .* rotate(Tinv{p},ori));
    
end

% for Reuss tensor invert back
TReuss = inv(TReuss);

% Hill is simply the mean of Voigt and Reuss averages
THill = 0.5*(TReuss + TVoigt);

% if type is specified only return this type
if check_option(varargin,'Reuss'), TVoigt = TReuss;end
if check_option(varargin,'Hill'), TVoigt = THill;end
