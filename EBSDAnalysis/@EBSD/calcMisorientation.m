function [mori,ori2] = calcMisorientation(ebsd1,varargin)
% calculate uncorelated misorientations between two ebsd phases
%
% Syntax
%   mori = calcMisorientation(ebsd,'sampleSize',1000)
%   mori = calcMisorientation(ebsd,'minDistance',100)
%   mori = calcMisorientation(ebsd1,ebsd2)
%   [ori1,ori2] = calcMisorientation(ebsd1)
%   plot(axis(ori1,ori2))
%
% Input 
%  ebsd, ebsd1, ebsd2 - @EBSD
%
% Output
%  m - @orientation, such that
%
%    $$m = (g{_i}^{--1}*CS^{--1}) * (CS *\circ g_j)$$
%
%   for two neighbored orientations $g_i, g_j$ with crystal @symmetry $CS$ of 
%   the same phase located on a grain boundary.
%
% See also
%

% get second ebsd set
ind = cellfun(@(c) isa(c,'EBSD'),varargin);
if any(ind)
  ebsd2 = varargin{find(ind,1)};
else
  ebsd2 = ebsd1;
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
else
  mori = ebsd1.orientations(i1);
  ori2 = ebsd2.orientations(i2);
end
