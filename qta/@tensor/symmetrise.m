function T = symmetrise(T)
% symmetrise a tensor according to its crystal symmetry

T = rotate(T,T.CS);
T = sum(T)/numel(T.CS);



