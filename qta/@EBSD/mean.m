function varargout = mean( ebsd,varargin)
% returns mean, kappas and eigenvector of ebsd object
%
%% Syntax
% [m lambda v kappa] = mean(ebsd) - 
%
%% Input
%  ebsd      - @EBSD
%
%% Output
%  m        - one equivalent mean @orientation
%  lambda   - eigenvalues of orientation tensor
%  v        - eigenvectors of orientation tensor
%  kappa    - parameters of bingham distribution
%

o = get(ebsd,'orientations');

% extract weights
if isfield(ebsd.options,'weight')
  [varargout{1:nargout}]  = mean(o,'weights',get(ebsd,'weight'),varargin{:});
else
  [varargout{1:nargout}]  = mean(o,varargin{:});
end
