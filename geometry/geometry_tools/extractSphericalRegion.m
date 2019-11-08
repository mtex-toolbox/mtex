function sR = extractSphericalRegion(varargin)

% TODO: maybe consider option 'antipodal'
sR = getClass(varargin,'sphericalRegion',[],'last');
sR = sphericalRegion(sR,varargin{:});
