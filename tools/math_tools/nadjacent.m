function A_D = nadjacent(A_Do, n)
%
% Returns the adjacency matrix of the n-neighbours.
%
  s = size(A_Do, 1);
  A_D = sparse(s, s);

  for i = 1:n
    A_D = A_D + A_Do^i;
  end
  
  % Remove diagonal
  if n > 1
    A_D = spones(A_D) - speye(s, s); 
  end
end