function [jc,ir,pr] = save_sparse(A)
% convert sparse matrix to jc, ir, pr
%
% Input
%  A - sparse matrix
% Output
%  jc -
%  ir -
%  pr -
%


[ir,j,pr] = find(A);
ir = ir - 1;

jc = zeros(1,size(A,2)+1);
for i = 1:numel(j), jc(j(i)+1) = jc(j(i)+1) + 1;end
jc = cumsum(jc);

%for i = 1:size(A,2)+1,	jc2(i) = sum(j < i);end
%plot([jc(100:200)',jc2(100:200)'])
