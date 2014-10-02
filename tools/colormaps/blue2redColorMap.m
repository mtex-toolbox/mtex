function rgb = blue2redColorMap(varargin)
% creates a colormap, ranging from dark blue via white to dark red.
%
% Nico Sneeuw
% Munich, 31/08/94

rgb = flipud(red2blueColorMap(varargin{:}));
