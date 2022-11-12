function SO3VF = normalize(SO3VF)
% Gives the normal vector of the tangential plane in v
%

SO3VF = SO3VF ./ norm(SO3VF);

end
