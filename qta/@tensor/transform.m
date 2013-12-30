function T = transform(T,CS)
% transform a tensor to a given crystal frame
%
%% Input
%  T  - @tensor
%  CS - crystal @symmetry
%
%% Output
%  T - @tensor
%

% compute the rotation between to the original and the new crystal frame
% get the original and the new axes
aOriginal = squeeze(double(get(T.CS,'axis')));
aNew = squeeze(double(get(CS,'axis')));

% compute the rotation matrix
R = aOriginal \ aNew;

% rotate the tensor
T = rotate(T,R);
