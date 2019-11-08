function [mori,ori2] = calcMisorientation(ebsd1,varargin)
% calculate the uncorrelated misorientations between two ebsd phases
%
% For two orientations $g_i$ and $g_j$ the misorientation is defined by 
% $ m = g_i^{-1} \circ g_j $.
%
% Syntax
%
%   % 1000 uncorrelated misorientations of phase1
%   mori = calcMisorientation(ebsd('phase1'),'sampleSize',1000)
%
%   % uncorrelated misorientations with minimum distance 100
%   mori = calcMisorientation(ebsd('phase1'),'minDistance',100)
%
%   %  uncorrelated misorientations between phase1 and phase2
%   mori = calcMisorientation(ebsd('phase1'),ebsd('phase2'))
%
%   % compute pairs of orientations to be used to compute axis
%   % distributions in specimen coordinates
%   [ori1,ori2] = calcMisorientation(ebsd('phase1'))
%   plot(axis(ori1,ori2),'contourf')
%
% Input 
%  ebsd - @EBSD
%
% Output
%  m - @orientation
%
% See also
%

% get second ebsd set
ind = cellfun(@(c) isa(c,'EBSD'),varargin);
isSamePhase = ~any(ind);
if isSamePhase
  ebsd2 = ebsd1;
else
  ebsd2 = varargin{find(ind,1)};
end

% function works only for single phases
checkSinglePhase(ebsd1);
checkSinglePhase(ebsd2);

% --------- determine minimum distance ----------------------

%extract coordinates
X1 = ebsd1.prop.x;
Y1 = ebsd1.prop.y;
X2 = ebsd2.prop.x;
Y2 = ebsd2.prop.y;

% get max extend
maxExtend = sqrt((max([X1;X2])-min([X1;X2]))^2 +...
  (max([Y1;Y2])-min([Y1;Y2]))^2);

minDistance = get_option(varargin,'minDistance',maxExtend/100);

% take a random sample
samplSize = get_option(varargin,'sampleSize',100000);

i1 = randi(length(ebsd1),samplSize,1);
i2 = randi(length(ebsd2),samplSize,1);

% ensure points are not to close together
d = sqrt((X1(i1)-X2(i2)).^2 + (X1(i1)-X2(i2)).^2);

ind = d > minDistance;
i1 = i1(ind); i2 = i2(ind);

if nargout <= 1
  % compute misorientations
  mori = ebsd1.orientations(i1) .\ ebsd2.orientations(i2);
  mori.antipodal = isSamePhase;
else
  mori = ebsd1.orientations(i1);
  ori2 = ebsd2.orientations(i2);
end
