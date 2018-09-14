function [val] = Clenshaw(alpha, beta, gamma, A, nodes)

N = length(A)-1;

it2 = repmat(A(N+1),size(nodes));
it1 = repmat(A(N),size(nodes));
for k=N:-1:2
  temp = A(k-1) + it2 * gamma(k+1);
  it2 = it1 + it2 .* (alpha(k+1) * nodes + beta(k+1));
  it1 = temp;
end
it2 = it1 + it2 .* (alpha(2) * nodes + beta(2));
val = it2 * gamma(1);

end

