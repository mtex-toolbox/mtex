function q = normalize(q)
% normalize quaternion 

q = q ./ norm(q);
