function ori = calcOrientations(odf,points,varargin)
% draw random orientations from ODF
%
% Syntax
%   ori = calcOrientations(odf,points)
%
% Input
%  odf    - @ODF
%  points - number of orientation to be simualted
%
% Output
%  ori   - @orientation
%
% See Also
% ODF_calcPoleFigure, ODF_calcEBSD

% distribute samples over the parts of the ODF
if length(odf.components) == 1
  iodf = ones(points,1);
else
  iodf = discretesample([odf.weights], points);
end

% preallocate orientations
ori = repmat(orientation(idquaternion,odf.CS,odf.SS),points,1);

% draw random sample from each component
for i = 1:numel(odf.components)

  ori(iodf==i) = discreteSample(odf.components{i},nnz(iodf==i),varargin{:});
    
end
