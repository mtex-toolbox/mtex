function l = not(grains)
% overloads not operator
%
%% Output
% l - logical array, where |true| indicates that the grain is not in the
%    GrainSet.
%
%% See also
% GrainSet/logical GrainSet/and GrainSet/or


l = ~logical(grains);