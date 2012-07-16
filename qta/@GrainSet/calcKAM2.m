function [ kam angles ] = calcKAM2(grains, neighbors, max_angle, varargin)
% intergranular average misorientation angle per orientation
%
%% Input
% grains    - @GrainSet of only one phase
% neighbors - number of neighbors to consider in the kernel
% max_angle - maximum misorientation angle (in radians)
%
%% Flags
% area      -  average all points inside the kernel (default)
% perimeter -  average only points along the perimeter of the kernel
%

if numel(unique(grains.phase)) > 1
    error('MTEX:MultiplePhases',...
          ['This operatorion is only permitted for a single phase!' ...
           'See ' doclink('xx','xx')  ...
           ' for how to restrict EBSD data to a single phase.']);
end

if neighbors <= 0
  error('MTEX:ValueError',...
        'The number of neighbors in the kernel must be greater than 0');
end

% Extract orientations and positions of voronois
orientations = get(grains, 'orientations'); 

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

% Calculate misorientation angle
angles_array = angle(orientations(Dl), orientations(Dr));

% Remove angles greater than the maximum angle
angles_array = angles_array .* (angles_array < max_angle);

% Create sparse matrix
angles = sparse(Dl, Dr, angles_array, n, n);

% Calculate KAM
kam = full(sum(angles, 2) ./ sum(angles > 0, 2));

end

% function d = distance(x0, y0, x1, y1)
% %
% % Returns the distance between two points
% %
% d = sqrt((y1 - y0).^2 + (x1 - x0).^2);
% end