function plotVariantPF(job, varargin)
% Plot pole figure of child variants
%
% Syntax
%   plotVariantPF(job)
%   plotVariantPF(job, oriParent)
%   plotVariantPF(job, hChild)
%   plotVariantPF(job, oriParent, hChild)
%
% Input
%  job - @parentGrainReconstructor
%  oriParent - @orientation Parent orientation
%  hChild - @Miller Plotting direction for the pole figure

plotVariants(job.p2c, varargin{:});
