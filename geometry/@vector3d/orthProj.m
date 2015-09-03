function v = orthProj(v,N)

N = normalize(N);
v = v(:) - dot(v,N) .* N;