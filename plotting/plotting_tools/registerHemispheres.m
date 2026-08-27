function registerHemispheres(ax)
% mark several axes as the halves of one and the same spherical plot
%
% Syntax
%   registerHemispheres([axUpper,axLower])
%
% Description
% A spherical region that covers the upper as well as the lower hemisphere
% is drawn into two axes - but it remains a single plot. Registering the
% halves with each other is what lets everything that is added later - a
% circle, a marker, a label - reach both of them, each showing the part of
% it that falls into its hemisphere.
%
% Input
%  ax - the axes the halves are drawn into
%
% See also
% sphericalPlot newSphericalPlot

ax = ax(isgraphics(ax,'axes'));
ax = ax(arrayfun(@(a) isappdata(a,'sphericalPlot'),ax));

if numel(ax) < 2, return; end

sP = getappdata(ax(1),'sphericalPlot');
for i = 2:numel(ax), sP(i) = getappdata(ax(i),'sphericalPlot'); end

[sP.hemispheres] = deal(sP);

end
