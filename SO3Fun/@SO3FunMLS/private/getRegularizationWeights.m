function regweights = getRegularizationWeights(deg)

% given a degree deg, we compute weights that punish higher degrees of the
%   coefficient vector of the local least squares problem
% the weights should be the same for all basis functions of the same degree

% treat easy cases, makes general case simpler to implement due to avoiding exceptions
if (deg == 0)
  regweights = 1;
  return;
elseif (deg == 1)
    regweights = [1, 1, 1, 1];
    return;
end

% MLS uses all degrees smaller than deg, which have the same parity as deg
num_degs = 1 + floor(deg / 2);
deg_is_odd = mod(deg, 2);
degs = 2 * (0 : num_degs-1)' + deg_is_odd;
dimensions = (degs + 1).^2;

% regweights = repelem(.95 .^ (deg_is_odd : 2 : deg)', dimensions) / (.8 ^ deg_is_odd);
regweights = repelem(1 ./ dimensions, dimensions);

end