function [R,G,B] = tsl2rgb(T,S,L)


x = -cot(2*pi*T);

ind = T > 0.5;
g = sqrt(5./(9*(x.^2+1))) .* S;
g(ind) = -g(ind);


ind = abs(T) < 1e-6;
g(ind) = 0;

r(ind) = sqrt(5)/3 * S(ind);
r(~ind) = x(~ind) .* g(~ind) + 1/3;

k = 1 ./ (0.185*r + 0.473*g + 0.114);

R = k * r;
G = k * g;
B = k * (1-r-g);


end

