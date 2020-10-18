function meanProp = grainMean(ebsd, prop, varargin)
% grain average property from ebsd properties
%
% Syntax
%
%   % recover grains and store grainId 
%   [grains,ebsd.grainId]=calcGrains(ebsd)
%
%   % compute average grain property
%   meanProp = grainMean(ebsd, ebsd.ci);
%   plot(grains,meanProp(grains.id))
%
%   % ensures meanProp has the same ordering as grains
%   meanProp = grainMean(ebsd, ebsd.ci, grains);
%
%   % take not the mean but the maximum per grain
%   meanProp = grainMean(ebsd, ebsd.ci, @max);
%
%   % full syntax
%   meanProp = grainMean(ebsd, prop, grains, method)
%
% Input
%  ebsd   - @EBSD (which must contain a grainId)
%  prop   - property to average, same size as ebsd
%  grains - @grain2d
%  method - function_handle
%
% Output
%  meanProp - average property, sorted by grainId
%  meanProp - average property, same size as grains (if specified)
%
% Options
%  ulim   - upper limit to consider (upper limit)
%  llim   - lower limit to consider (lower limit)
%

% check for grainId
if isempty(ebsd.grainId)
  error('There is no ebsd.grainId. Run calcGrains first.')
end

% some limits
ulim = get_option(varargin,'ulim', max(prop));
llim= get_option(varargin,'llim',min(prop));
prop(prop<llim | prop > ulim)=nan;

% ignore ebsd data without grainId
hasGrain = ebsd.grainId>0;

% get averaging method
method = getClass(varargin,'function_handle',@nanmean);

% perform the averaging
meanProp = accumarray(ebsd.grainId(hasGrain),prop(hasGrain),[],method);

% convert from id to ind
grains = getClass(varargin,'grain2d');
if ~isempty(grains), meanProp = meanProp(grains.id); end

end