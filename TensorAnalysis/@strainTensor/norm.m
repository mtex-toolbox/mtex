function n = norm(epsilon)
% spectral norm 

n = reshape(max(abs(eig3(epsilon.M)),[],1),size(epsilon));

end
