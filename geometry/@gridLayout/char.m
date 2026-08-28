function c = char(gL)
% the layout as its name, or as the class when it has none

if isempty(gL.name)
  c = class(gL);
else
  c = gL.name;
end

end
