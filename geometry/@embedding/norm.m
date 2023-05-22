function n = norm(obj,varargin)

n = 0;
for i = 1:length(obj.u)
  n = n + norm(obj.u{i}).^2;
end
n = sqrt(n);

if check_option(varargin,'normalized')
  n = n ./ norm(embedding.id(obj.CS));
end


end