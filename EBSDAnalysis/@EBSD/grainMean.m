function [gmp, gid] = grainMean(ebsd,prop,varargin)
% calculate grain average scalar properties based on all ebsd
% points that are within a grain
%
%  Syntax
%     [grains,ebsd.grainId]=calcGrains(ebsd)
%     [gmp, gid] = grainMean(ebsd,ebsd.ci)
%     plot(grains(gid),gmp)
%
%
%  Input
%      ebsd - @EBSD (which must contain a grainID)
%      prop - property to average (of length(ebsd))
%
%  Output
%      gmp   - average property (of length grainID)
%      gid   - grainId from ebsd of length(property)
%
%   Options
%      ulim  - upper limit to consider (upper limit)
%      llim  - lower limit to consider (lower limit)
%


%   check if grainID exists
if isempty(ebsd.grainId)
    error('There is no ebsd.grainId. Run calcGrains first.')
end
%ss
prop = prop(:);
ulim = get_option(varargin,'ulim', max(prop));
llim= get_option(varargin,'llim',min(prop));

prop(prop<llim | prop > ulim)=nan;
%find ebsd.grainID and index of corresponding prop
[gid,~,eindex] = unique(ebsd.grainId);
% calc the mean, ignoring nans
gmp = accumarray(eindex,prop,[],@nanmean);
% Todo allow diffrent averaging methods

end