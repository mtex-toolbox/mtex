function v = volume(oR,varargin)
% volume of an orientation region
%

% TODO: Do this faster

if nargin == 1, S3G = equispacedSO3Grid(oR.CS1,oR.CS2,'resolution',5*degree); end

v = nnz(oR.checkInside(S3G))/length(S3G);
