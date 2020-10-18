function n = norm(obj)

n = 0;
for i = 1:length(obj.u)
  n = n + norm(obj.u{i}).^2;
end
n = sqrt(n);

end