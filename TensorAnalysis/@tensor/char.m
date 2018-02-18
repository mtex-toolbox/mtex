function s = char(T)
% tensor to char

s = ['rank: '  num2str( T.rank), ', symmetry: ' char(T.CS) ];
