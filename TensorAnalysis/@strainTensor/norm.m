function n = norm(epsilon)

n = reshape(max(abs(eig3(epsilon.M)),[],1),size(epsilon));

end

