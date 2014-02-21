function varargout = mean( ebsd,varargin)
% returns mean, kappas and eigenvector of ebsd object
%
% Syntax
% [m lambda v kappa] = mean(ebsd) - 
%
% Input
%  ebsd     - @EBSD
%
% Output
%  m        - one equivalent mean @orientation
%  lambda   - eigenvalues of orientation tensor
%  v        - eigenvectors of orientation tensor
%  kappa    - parameters of bingham distribution
%

[varargout{1:nargout}]  = mean(ebsd.orientations,'weights',ebsd.weights,varargin{:});

