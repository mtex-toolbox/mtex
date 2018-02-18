function sR = extractSphericalRegion(varargin)

% TODO: maybe consider option 'antipodal'
sR = getClass(varargin,'sphericalRegion');
sR = sphericalRegion(sR,varargin{:});
