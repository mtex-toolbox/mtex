function ori = calcEBSD(odf,points,varargin)
% simulate EBSD data from ODF
%
% Syntax
%   ebsd = calcEBSD(odf,points)
%
% Input
%  odf    - @ODF
%  points - number of orientation to be simualted
%
% Output
%  ebsd   - @EBSD
%
% See Also
% ODF_calcPoleFigure

% distribute samples over the parts of the ODF
if length(odf) == 1
  iodf = ones(points,1);
else
  iodf = discretesample([odf.weight], points);
end

% preallocate orientations
ori = repmat(orientation(idquaternion,odf(1).CS,odf(1).SS),points,1);

% draw random sample from each component
for i = 1:numel(odf)

  ori(iodf==i) = discreteSample(odf(i),nnz(iodf==i),varargin{:});
    
end

ori = EBSD(ori);
