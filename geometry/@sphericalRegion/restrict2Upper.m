function sR = restrict2Upper(sR,ref)
 
if nargin==1
  ref = sR.how2plot.outOfScreen;
elseif isa(ref,'plottingConvention')
  ref = ref.outOfScreen;
end

% restricting twice to the same hemisphere must not add the condition a
% second time - the boundary is drawn once per condition, so a duplicate
% makes sphericalRegion/plot draw the very same circle twice. This happens
% e.g. for plotPDF(...,'upper'), where the region is already restricted
% before the 'upper' option is evaluated in newSphericalPlot/getPlotRegion
if any(dot(sR.N(:),ref) > 1-1e-10 & sR.alpha(:) >= 0), return; end

% the new condition is stated in the coordinates of the region, but it is
% prepended and vector3d/cat takes all its properties from the first
% argument - so the frame of the region has to be restored explicitly
fr = sR.frame;
sR.N = [ref;sR.N(:)];
sR.alpha = [0;sR.alpha(:)];
sR.frame = fr;

end
