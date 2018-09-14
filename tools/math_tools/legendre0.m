function l = legendre0(N,x)
% Legendrepolynome bis zur Odnung N
% und gibt sie als Matrix zur�ck
% erste Dimension -> Ordnung
% zweite Dimension -> x


x = x(:).';
l(1,:) = ones(1,length(x));
if N == 0, return; end
l(2,:) = x;
if N == 1, return; end
l(3,:) = (3*x.^2 - 1)/2;

for i = 2:N-1
    l(i+2,:) = ((2*i+1) * x .* l(i+1,:) - (i) * l(i,:))/(i+1);
end

