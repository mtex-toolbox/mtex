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

% ensure we have a variantMap
if isempty(job.variantMap)
  job.variantMap = 1:length(variants(job.p2c));
end

plotVariants(job.p2c, 'variantMap', job.variantMap, varargin{:});
