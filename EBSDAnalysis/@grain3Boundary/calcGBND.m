function gbnd = calcGBND(gB3,varargin)
% computes normal vectors of each face

n = gB3.faceNormals;

gbnd = calcDensity(n,'weights',gB3.area,varargin{:});

end