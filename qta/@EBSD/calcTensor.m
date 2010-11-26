function Tavarage = calcTensor(ebsd,varargin)
% compute the mean tensor for an EBSD data set
%
%% Syntax
% T = calcTensor(ebsd,T_phase1,T_phase2,'voigt')
% T = calcTensor(ebsd,T_phase2,'reuss','phase',2)
% T = calcTensor(ebsd,T_phase1,T_phase2,'hill')
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


% Hill tensor is just the avarage of voigt and reuss tensor
if check_option(varargin,'hill')
  varargin = delete_option(varargin,{'hill'});
  Tavarage = .5*(calcTensor(ebsd,T{:},'voigt',varargin{:}) + calcTensor(ebsd,T{:},'reuss',varargin{:}));
  return
end

% for Reuss tensor invert tensor
if check_option(varargin,'reuss')
  T = cellfun(@(t) inv(t),varargin,'uniformOutput',false);
end

% restrict phases if necassary
if check_option(varargin,'phase')
  phases = get_option(varargin,'phase');
  [SO3,ind] = get(ebsd,'orientations',varargin{:});
  ebsd = ebsd(ind);
else
  phases = get(ebsd,'phase');
end

% initialize avarage tensor
Tavarage = tensor(zeros(size(T{1})));
sZ = sampleSize(ebsd);

% cycle through phases and tensors
for i = 1:min(length(T),length(ebsd))
  
  % extract orientations and wights
  [SO3,ind] = get(ebsd,'orientations','phase',phases(i));
  weight = get(ebsd(ind),'weight')*sum(sZ(ind))./sum(sZ);

  % extract tensor
  Tphase = T{i};

  % rotate tensor according to the orientations
  Tphase = rotate(Tphase,SO3);

  % take the mean of the tensor times the weight
  Tavarage = Tavarage + sum(weight .* Tphase);
    
end

% for Reuss tensor invert back
if check_option(varargin,'reuss'), Tavarage = inv(Tavarage);end
