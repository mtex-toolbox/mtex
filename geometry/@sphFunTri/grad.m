function g = grad(sF, v) % gradient

if nargin == 2 % direct evaluation
  v = v(:);
  bario = sF.calcBario(v);
  g = vector3d(zeros(3, length(v)));
  for i = 1:length(v)
    I = find(bario(i, :));
    if length(I) == 3
      f = sF.values(I);
      v = sF.vertices(I);
      g(i) = vector3d(v.xyz\(f(:)-(f(1)+f(2)+f(3))/3*ones(3, 1)));
    end
  end
else % return sphVectorField
  sT = sF.midPoints;
  g = sphVectorFieldTri(sT, sF.grad(sF.midPoints));
end

end
