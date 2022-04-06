function l = legendre0(N,x)
% Evaluate all Legendre polynomials up to degree N in x and returns a 
% matrix of the function values
%       1st dimension -> degree
%       2nd dimension -> x


x = x(:).';
l(1,:) = ones(1,length(x));
if N == 0, return; end
l(2,:) = x;
if N == 1, return; end
l(3,:) = (3*x.^2 - 1)/2;

for i = 2:N-1
    l(i+2,:) = ((2*i+1) * x .* l(i+1,:) - (i) * l(i,:))/(i+1);
end

