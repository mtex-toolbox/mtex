function varargout = mean( ebsd,varargin)
% returns mean, kappas and eigenvector of ebsd object
%
%% Syntax
% [m kappa v] = mean(ebsd)
%
%% Input
%  ebsd      - @EBSD
%
%% Output
%  m        - one equivalent mean orientation @quaternion
%  lambda   - eigenvalues of orientation tensor
%  v        - eigenvectors of orientation tensor
%  kappa    - parameters of bingham distribution
%

[o,ind] = get(ebsd,'orientations','CheckPhase',varargin{:});

% extract weights
if isfield(ebsd(1).options,'weight')
  [varargout{1:nargout}]  = mean(o,'weights',get(ebsd(ind),'weight'),varargin{:});
else
  [varargout{1:nargout}]  = mean(o,varargin{:});
end
