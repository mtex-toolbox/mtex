function bario = calcZeroBario(v1,v2,v3,v4)
% compute bariocentric coordinates of the vector (0,0,0)
% in the triangle v1, v2, v3

bario(:,1) = dot(cross(v2,v3),v4);
bario(:,2) = -dot(cross(v1,v3),v4);
bario(:,3) = dot(cross(v1,v2),v4);
bario(:,4) = -dot(cross(v1,v2),v3);

bario = bario ./ repmat(sum(bario,2),1,4);

end
