function [ m kappa v] = mean( ebsd,varargin)
% returns mean, kappas and eigenvector of ebsd object
%
%% Input
%  ebsd      - @ebsd
%
%% Output
%  m         - one equivalent mean orientation @quaternion
%  kappa     - parameters of bingham distribution
%  v         - eigenvectors of kappa
%

[S3G,ind] = getgrid(ebsd,'CheckPhase',varargin{:});

% extract weights
if isfield(ebsd(1).options,'weight')
  weight = get(ebsd(ind),'weight');
else
  weight = ones(1,GridLength(S3G));
end

[m kappa  v]  = mean(S3G,'weights',weight);

