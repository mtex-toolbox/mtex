function c = extensionDirection(L)
% extension direction

[c,~] = eig(sym(L));

c = c(:,3);

