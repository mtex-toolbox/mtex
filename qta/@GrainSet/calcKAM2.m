function [ kam angles ] = calcKAM2(grains, neighbors, maxAngle, varargin)
% intergranular average misorientation angle per orientation
%
%% Input
% grains    - @GrainSet
% neighbors - number of neighbors to consider in the kernel
% maxAngle - maximum misorientation angle (in radians)
%
%% Flags
% area      -  average all points inside the kernel (default)
% perimeter -  average only points along the perimeter of the kernel
%

if neighbors <= 0
  error('MTEX:ValueError',...
        'The number of neighbors in the kernel must be greater than 0');
end

if maxAngle <= 0
  error('MTEX:ValueError',...
        'The maximum angle must be greater than 0');
end

% Extract orientations and positions of voronois
CS = get(grains, 'CSCell');
SS = get(grains, 'SS');
r = get(grains.EBSD, 'quaternion');
phaseMap = get(grains, 'phaseMap');
phase = get(grains.EBSD, 'phase');
isIndexed = ~isNotIndexed(grains.EBSD);

% Readjust indexes of A_D to the restrained set of voronois included 
% in the given grain set. This adjustment must be performed before 
% selecting the voronois inside the grains.
A_D = grains.A_D;
b = find(any(grains.I_DG, 2));
A_D = A_D(b, b);

% Select only voronois inside the grains
n = size(A_D, 1);
I_FD = grains.I_FDext | grains.I_FDsub;
[d,~] = find(I_FD(sum(I_FD, 2) == 2, any(grains.I_DG, 2))');
Dl = d(1:2:end);
Dr = d(2:2:end);
A_D = A_D - sparse(Dl, Dr, 1, n, n);
A_D = A_D | A_D';

A_D = double(A_D);

% Find neighboring points for the specified kernel
if check_option(varargin, 'perimeter')
  A_D = nadjacent(A_D, neighbors) - nadjacent(A_D, neighbors - 1);
else
  A_D = nadjacent(A_D, neighbors);
end

% Pairs of adjacent voronois
[Dl Dr] = find(A_D);

% Delete adjacenies between different phase and not indexed measurements
use = phase(Dl) == phase(Dr) & isIndexed(Dl) & isIndexed(Dr);
Dl = Dl(use); Dr = Dr(use);
phase = phase(Dl);

% Calculate misorientation angles
prop = []; zeros(size(Dl));
for p=1:numel(phaseMap)
  currentPhase = phase == phaseMap(p);
  if any(currentPhase)
    o_Dl = orientation(r(Dl(currentPhase)), CS{p}, SS);
    o_Dr = orientation(r(Dr(currentPhase)), CS{p}, SS);
    
    m  = o_Dl .\ o_Dr; % Misorientation
    prop(currentPhase, :) = angle(m); %#ok<AGROW>
  end
end

% Remove angles greater than the maximum angle
prop(prop > maxAngle) = 0.0;

% Create sparse matrix
angles = sparse(Dl, Dr, prop, n, n);

% Calculate KAM
kam = full(sum(angles, 2) ./ sum(angles > 0, 2));
kam(isnan(kam)) = maxAngle;

end

% function d = distance(x0, y0, x1, y1)
% %
% % Returns the distance between two points
% %
% d = sqrt((y1 - y0).^2 + (x1 - x0).^2);
% end