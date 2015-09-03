function plot(oM,varargin) 
% plot colorbar with patala misorientation colorcoding

% patala is only defined for antipodal
oS = axisAngleSections(oM.CS1,oM.CS2,'antipodal',varargin{:});
ori = oS.makeGrid(varargin{:});
rgb = oM.orientation2color(ori);
plot(oS,rgb,'surf',varargin{:});
