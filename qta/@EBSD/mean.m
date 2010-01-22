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
%  m         - one equivalent mean orientation @quaternion
%  kappa     - parameters of bingham distribution
%  v         - eigenvectors of kappa
%

[o,ind] = get(ebsd,'orientations','CheckPhase',varargin{:});

% extract weights
if isfield(ebsd(1).options,'weight')
  [varargout{1:nargout}]  = mean(o,'weights',get(ebsd(ind),'weight'));
else
  [varargout{1:nargout}]  = mean(o);
end
