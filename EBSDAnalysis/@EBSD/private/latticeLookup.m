function [ij2ebsd,ij2slot,ijMin,ijSize] = latticeLookup(ij)
% fast (i,j) -> ebsd index lookup table over the bounding box of ij
%
% ij2ebsd(ij2slot([i j])) is the ebsd index at lattice coordinate (i,j), for
% (i,j) within [ijMin, ijMin+ijSize-1] - callers must bounds check against
% ijMin/ijSize themselves before calling ij2slot, e.g.
%
%   inBox = IJn(:,1)>=ijMin(1) & IJn(:,1)<=ijMin(1)+ijSize(1)-1 & ...
%           IJn(:,2)>=ijMin(2) & IJn(:,2)<=ijMin(2)+ijSize(2)-1;
%   idx = zeros(size(IJn,1),1);
%   idx(inBox) = ij2ebsd(ij2slot(IJn(inBox,:)));
%
% Shared by @EBSD/KAM.m and @EBSD/curvature.m.
%
% Input
%  ij - nEbsd × 2 integer lattice indices
%
% Output
%  ij2ebsd - lookup table
%  ij2slot - function handle, flattens n × 2 integer (i,j) pairs into
%            linear slots into ij2ebsd
%  ijMin   - 1x2 minimum (i,j) of the bounding box
%  ijSize  - 1x2 size of the bounding box

ijMin = min(ij,[],1);
ijSize = max(ij,[],1) - ijMin + 1;
ij2slot = @(IJ) (IJ(:,1)-ijMin(1)) + (IJ(:,2)-ijMin(2))*ijSize(1) + 1;

ij2ebsd = zeros(prod(ijSize),1);
ij2ebsd(ij2slot(ij)) = 1:size(ij,1);

end
