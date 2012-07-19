function mypcolor(A)
% reimplements pcolor such that borders are plotted to

A = [A,A(:,end)];
A = [A;A(end,:)];
pcolor(A);
