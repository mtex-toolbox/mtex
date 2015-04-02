function plot(oM,varargin) 
% plot colorbar with patala misorientation colorcoding

oS = axisAngleSections(oM.CS1,oM.CS2);
ori = oS.makeGrid(varargin{:});
rgb = oM.orientation2color(ori);
plot(oS,rgb,'surf',varargin{:});
