function f = eval(SO3F,rot,varargin)
% eval function at given rotations
%

%     if isa(rot,'orientation')
%       ensureCompatibleSymmetries(SO3F,rot)
%     end

f = 0;
for k = 1:length(SO3F.components)
  f = f + eval(SO3F.components{k},rot,varargin{:});
end

if isalmostreal(f)
  f = real(f);
end

end