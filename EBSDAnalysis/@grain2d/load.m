function [grains] = load(filepath)
% load tesselation data from neper files
%
% Description
%
% grain2d.load is a method to load the data from the tesselation files that
% <neper.info/ neper> outputs (only 2 dimesional tesselations!)
%
% Syntax
%   grains = grain2d.load('filepath/filename.tess')
%
% Input
%  fname     - filename
%
% Output
%  grain2d - @grain2d
%
% Example
%
%   
%   grains = grain2d.load(fname)
%
% See also
% readTessFile

%filepath="2dslice.tess";

%%
[dimension,V,poly,oriMatrix,crysym] = readTessFile(filepath);

if (dimension~=2)
    error 'format is not 2 - only two dimesional tesselations allowed'
end

CSList={'notIndexed',crystalSymmetry(crysym)};
rot=rotation(quaternion(oriMatrix'));
phaseList=2*ones(size(poly));

grains = grain2d(V,poly,rot,CSList,phaseList);

%% check for clockwise poly's

isNeg = (grains.area<0);
grains.poly = cellfun(@fliplr, grains.poly(isNeg), 'UniformOutput', false);

grains = grain2d(V,poly,rot,CSList,phaseList);



