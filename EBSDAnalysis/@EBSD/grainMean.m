function meanProp = grainMean(ebsd, prop, varargin)
% grain average property from ebsd properties
%
% Syntax
%
%   % recover grains and store grainId 
%   [grains,ebsd.grainId] = calcGrains(ebsd)
%
%   % compute average grain property
%   meanPropG = grainMean(ebsd, ebsd.ci, grains);
%   plot(grains,meanPropG)
%
%   % compute average grain property for each EBSD pixel
%   meanPropE = grainMean(ebsd, ebsd.ci, grains);
%   plot(ebsd,meanPropE)
%
%   % take not the mean but the maximum per grain
%   meanPropG = grainMean(ebsd, ebsd.ci, grains, @max);
%   plot(grains,meanPropG)
%
% Input
%  ebsd   - @EBSD (which must contain a grainId)
%  prop   - property to average, same size as ebsd
%  grains - @grain2d
%  method - function_handle
%
% Output
%  meanPropG - average property, sorted as grains
%  meanPropE - average property, sorted as EBSD
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
method = getClass(varargin,'function_handle',@(x) mean(x,1,"omitmissing"));

% perform the averaging
mP = accumarray(ebsd.grainId(hasGrain),prop(hasGrain),[],method);

grains = getClass(varargin,'grain2d');
if  ~isempty(grains)
  % convert from grainId to grainIndex
  meanProp = mP(grains.id);
else
  % convert to ebsd index
  meanProp = nan(size(ebsd));
  meanProp(ebsd.grainId>0) = mP(ebsd.grainId(ebsd.grainId>0));
end

end