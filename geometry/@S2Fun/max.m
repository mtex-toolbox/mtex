function v = max(sF1, sF2)

if nargin == 1
  v = min(-sF1);
else
  v = -min(-sF1,-sF2);
end

end
