function ps = measureShift(mgRef,imRef,mgTest,imTest,roi)
% the shifts between two images on one grid, tile by tile
%
% Input
%  mgRef, mgTest - @mapImage, the grids the two images sit on
%  imRef, imTest - the images to correlate, e.g. their edge transforms
%  roi           - struct with ROISize and NumROI, in pixels
%
% Output
%  ps - @pairShifts, u pointing from where a tile of the test image is to
%       where it is in the reference

mgRef.img = imRef; mgTest.img = imTest;

[u,peak,pos] = xcfShift(mgRef,mgTest,'ROISize',roi.ROISize,'numROI',roi.NumROI);

% xcfShift measures where a feature of the reference sits in the test image
ps = pairShifts(pos,-u,peak,roi.ROISize);

end
