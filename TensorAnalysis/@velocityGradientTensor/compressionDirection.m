function c = compressionDirection(L)
% compression direction

[c,~] = eig(sym(L));

c = c(:,1);


