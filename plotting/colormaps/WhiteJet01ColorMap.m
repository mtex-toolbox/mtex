function [map] = WhiteJet01ColorMap(cmax,varargin)
%WHITEJET01COLORMAP fix bottom of jet colourmap at 1 and white at 0
% when plotting ODFs with WhiteJetColorMap it might be useful to define 
% an additional fixed point at MUD = 1 to compare texture strengths
% 1 (uniform ODF / random texture) = dark blue (min in Jet colormap)
% cmax (ODF mode / texture peak) = red (max in Jet colormap)
% 0 (never found in ODF) = white 
  

if nargin <1
    map = WhiteJetColorMap;
    return
end

% the colourscale should be linearly spaced between 0 and cmax
if nargin ==1
    n=max(100,cmax*2);%make sure that a white step does exist!!! 
    %(it might disappear if cmax is nearly as big as n)
elseif nargin > 1
    varargin{1}=n;
end
%number of steps between 0 (white) and 1 (min colour of jet)
n01 = round((1/cmax)*n);
%number of steps between 1 and cmax
n1max = n-n01+1; % 1 extra step because the two maps will overlap at the bottom


map1max = jet(n1max); %normal jet
map01 =  makeColorMap([1 1 1], map1max(1,:), n01); %white to bottom of jet
%concatenate to construct final map
map = [map01;map1max(2:end,:)];

end
