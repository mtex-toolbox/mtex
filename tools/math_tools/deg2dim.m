function d = deg2dim(l)
% dimension of the harmonic space up to order l

dimensions = size(l);
l = l(:);

d = l .* (2*l - 1) .* (2*l + 1) / 3;
d = reshape(d, dimensions);

end
