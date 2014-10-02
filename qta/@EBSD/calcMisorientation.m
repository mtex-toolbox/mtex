function [mori,weights] = calcMisorientation(ebsd1,varargin)
% calculate uncorelated misorientations between two ebsd phases
%
%% Input 
% ebsd - @EBSD
%
%% Output
% m - @orientation, such that
%
%    $$m = (g{_i}^{--1}*CS^{--1}) * (CS *\circ g_j)$$
%
%   for two neighbored orientations $g_i, g_j$ with crystal @symmetry $CS$ of 
%   the same phase located on a grain boundary.
%
%% See also
%

%% get second ebsd set
ind = cellfun(@(c) isa(c,'EBSD'),varargin);
if any(ind)
  ebsd2 = varargin{find(ind,1)};
else
  ebsd2 = ebsd1;
end

% function works only for single phases
checkSinglePhase(ebsd1);
checkSinglePhase(ebsd2);

%% determine minimum distance

%extract coordinates
X1 = get(ebsd1,'X');
Y1 = get(ebsd1,'Y');
X2 = get(ebsd2,'X');
Y2 = get(ebsd2,'Y');

% get max extend
maxExtend = sqrt((max([X1;X2])-min([X1;X2]))^2 +...
  (max([Y1;Y2])-min([Y1;Y2]))^2);

minDistance = get_option(varargin,'minDistance',maxExtend/100);


%% take a random sample

samplSize = get_option(varargin,'sampleSize',100000);

i1 = randi(numel(ebsd1),samplSize,1);
i2 = randi(numel(ebsd2),samplSize,1);

%% ensure points are not too close together

d = sqrt((X1(i1)-X2(i2)).^2 + (X1(i1)-X2(i2)).^2);

ind = d > minDistance;

i1 = i1(ind);
i2 = i2(ind);

%% compute misorientations

o1 = get(ebsd1,'orientations');
o2 = get(ebsd2,'orientations');

mori = o1(i1) .\ o2(i2);

% compute weights
weights = ones(size(mori)) ./ numel(mori);
