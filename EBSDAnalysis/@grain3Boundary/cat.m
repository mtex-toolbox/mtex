function gB = cat(dim, varargin)
% implements [gB1,gB2]
%
% Syntax
%   gB = [gB1,gB2,gB3]
%
% Input
%  gB - @grain3Boundary
%

gB = cat@dynProp(dim,varargin{:});

for k = 2:numel(varargin)
  ngB = varargin{k};
  
  assert(length(gB.allV) == length(ngB.allV) && all(isnull(gB.allV-ngB.allV)),...
    "concatenation is only possible for grain-sets with identical Point Sets")

  [gB.id,IA,IB] = union(gB.id , ngB.id, 'stable');
  gB.F = [gB.F(IA,:) ; ngB.F(IB,:)];
    
end

end
