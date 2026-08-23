function [bandPass,window] = xcfFilters(roiSize,fPass)
% the band pass and window a cross correlation tile is filtered by
%
% The window tapers the tile to zero at its edges, so that the periodic
% assumption behind an FFT correlation does not manufacture an edge. The
% band pass drops the frequencies that carry no registrable structure -
% the lowest, which are illumination gradients, and the highest, which are
% noise.
%
% Syntax
%
%   [bandPass,window] = xcfFilters(roiSize,fPass)
%
% Input
%  roiSize - tile width in pixels
%  fPass   - [highCutOff highWidth lowCutOff lowWidth]
%
% Output
%  bandPass - roiSize x roiSize, in fft order
%  window   - roiSize x roiSize raised cosine
%
% See also
% xcfShift

lCutOff = fPass(3); lWidth = fPass(4)/2;
hCutOff = fPass(1); hWidth = fPass(2)/2;

assert(lCutOff >= hCutOff,'MTEX:xcfShift:badBand',...
  'The low pass cut off %g is below the high pass cut off %g.',lCutOff,hCutOff);

[v,u] = meshgrid(1:roiSize,1:roiSize);
v = v - roiSize/2 - 0.5;
u = u - roiSize/2 - 0.5;

window = cos(pi.*u/roiSize) .* cos(pi.*v/roiSize);

d = hypot(u,v);

low = exp(-((d - lCutOff)/(sqrt(2)*lWidth/2)).^2);
low(d > lCutOff + 2*lWidth) = 0;
low(d < lCutOff) = 1;

high = exp(-((hCutOff - d)/(sqrt(2)*hWidth/2)).^2);
high(d < hCutOff - 2*hWidth) = 0;
high(d > hCutOff) = 1;

bandPass = fftshift(high .* low);

end
