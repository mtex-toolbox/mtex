function out = ind2char(i,s)
% calculates coordinate from one index
% i - index
% s - size of matrix


out = '(';
for d = 1:length(s)
	out = [out,int2str(mod(ceil(i/prod(s(1:d-1)))-1,s(d))+1),',']; %#ok<AGROW>
end
out(end) = ')';

