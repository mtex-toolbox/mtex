function vals = eval_monomials(v, deg, varargin)
% eval all monomials of degree deg, deg-2, ..., mod(deg,2) on v
% leave some out since we assume that v are spherical vectors, 
% hence x^2+y^2+z^2 = 1
% tangent is boolean - if true we set the z coordinate to 1 

% get the number of functions corresponding to the degree
dim = (deg + 1) * (deg + 2) / 2;

% extract the coordinates for nicer code
x = v.x; y = v.y; z = v.z;

if nargin == 3 && varargin{1} == true
    z = ones(size(z));
end
% initialize vals
vals = zeros(numel(x), dim);

% even case 
if mod(deg, 2) == 0
    vals(:,1) = 0 * x + 1;
    if deg >= 2
        vals(:,[2 3]) = [x y] .* z;
        vals(:,[4 5]) = [x y].^2;
        vals(:,6) = x .* y;
    end
    if deg >= 4
        vals(:,[7 8]) = [x y].^3 .* z;
        vals(:,[9 10]) = x .* y .* z .* [x y];
        vals(:,[11 12]) = [x y].^4;
        vals(:,[13 14]) = x .* y .* [x y].^2;
        vals(:,15) = x.^2 .* y.^2;
    end
    if deg >= 6
        vals(:,[16 17]) = [x y].^5 .* z;
        vals(:,[18 19]) = x .* y .* z .* [x y].^3;
        vals(:,[20 21]) = x.^2 .* y.^2 .* z .* [x y];
        vals(:,[22 23]) = [x y].^6;
        vals(:,[24 25]) = x .* y .* [x y].^4;
        vals(:,[26 27]) = x.^2 .* y.^2 .* [x y].^2;
        vals(:,28) = x.^3 .* y.^3;
    end
% odd case
else
    if deg >= 1
        vals(:,[1 2 3]) = [z x y];
    end
    if deg >= 3
        vals(:,[4 5]) = [x y].^2 .* z;
        vals(:,6) = x .* y .* z;
        vals(:,[7 8]) = [x y].^3;
        vals(:,[9 10]) = x .* y .* [x y];
    end
    if deg >= 5
        vals(:,[11 12]) = [x y].^4 .* z;
        vals(:,[13 14]) = x .* y .* z .* [x y].^2;
        vals(:,15) = x.^2 .* y.^2 .* z;
        vals(:,[16 17]) = [x y].^5;
        vals(:,[18 19]) = x .* y .* [x y].^3;
        vals(:,[20 21]) = x.^2 .* y.^2 .* [x y];
    end
end

end
