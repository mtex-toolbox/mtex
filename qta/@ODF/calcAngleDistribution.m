function [density,omega] = calcAngleDistribution(odf,varargin)
% compute the angle distribution of an ODF or an MDF 
%
%
%% Input
%  odf - @ODF
%  omega - list of angles
%
%% Flags
%  EVEN       - calculate even portion only
%
%% Output
%  x   - values of the axis distribution
%
%% See also

% get resolution
points = get_option(varargin,'points',100000);
res = get_option(varargin,'resolution',2.5*degree);

%% simluate EBSD data
ebsd = simulateEBSD(odf,points,'resolution',res);

% compute angles
angles = angle(get(ebsd,'orientations'));

maxangle = max(angles);


%% perform kernel density estimation

[bandwidth,density,omega,cdf] = kde(angles,2^8,0,maxangle);


% where to evaluate
%omega = linspace(0,maxangle,100);

% 
%sigma = 20;
%psi = @(a,b) exp(-(a-b).^2*sigma.^2);

%
%x = sum(bsxfun(psi,angles,omega));
%x = x./sum(x)*numel(x);
