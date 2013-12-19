function m = repentry(A,f)
% reshape by element

dim = ndims(A);
s = size(A);

m = A;

for i = 1:length(f)
    m = reshape(m,[s(1:i-1),1,s(i:dim)]);
    d = repmat(1,[1,dim]);
    d(i) = f(i);
    s = s .* d;
    m = repmat(m,d);
    m = reshape(m,s);
end
