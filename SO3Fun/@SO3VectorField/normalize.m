function sVF = normalize(sVF)
%
% Gives the normal vector of the tangential plane in v
%

sVF = sVF ./ norm(sVF);

end
