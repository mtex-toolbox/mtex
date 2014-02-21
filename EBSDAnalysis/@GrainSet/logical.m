function l = logical( grains )
% convert GrainSet into a logical array
%
%% Input
% grains - @GrainSet
%% Output
% l - logical array, where |true| indicates that the grain is in the
%    GrainSet and |false| that, the grain is not in the GrainSet,
%    where the logical entry referres to the position of the complete
%    GrainSet.


l = reshape(full(any(grains.I_DG,1)),[],1);

