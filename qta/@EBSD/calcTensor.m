function [TVoigt, TReuss, THill] = calcTensor(ebsd,varargin)
% compute the average tensor for an EBSD data set
%
%% Syntax
% [TVoigt, TReuss, THill] = calcTensor(ebsd,T_phase1,T_phase2,...) - returns 
%    the Voigt--, Reuss-- and Hill-- @tensor, applies each tensor
%    given in order of input to each phase
%
% [TVoigt, TReuss, THill] = calcTensor(ebsd('phase2'),T_phase2) - returns the Voigt--, 
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

% initialize avarage tensors
TVoigt = tensor(zeros(size(T{1})));
TReuss = tensor(zeros(size(T{1})));

% get phases and populate tensors
phases = unique(ebsd.phases)';
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
  
  % extract orientations and wights
  ind = ebsd.phases == p;
  ori = get(subsref(ebsd,ind),'orientations');    
  weight = get(subsref(ebsd,ind),'weight') * nnz(ind) ./ numel(ebsd);

  % take the mean of the rotated tensors times the weight
  TVoigt = TVoigt + sum(weight .* rotate(T{p},ori));
  
  % take the mean of the rotated tensors times the weight
  TReuss = TReuss + sum(weight .* rotate(inv(T{p}),ori));
    
end

% for Reuss tensor invert back
TReuss = inv(TReuss);

% Hill is simply the mean of Voigt and Reuss averages
THill = 0.5*(TReuss + TVoigt);

% if type is specified only return this type
if check_option(varargin,'Reuss'), TVoigt = TReuss;end
if check_option(varargin,'Hill'), TVoigt = THill;end
