function dispLine(s)
% display symmetry as a one-liner

if ~isempty(s.mineral)
  disp([' mineral: ',char(s,'verbose')]);
else
  disp([' crystal symmetry:  ',char(s,'verbose')]);
end

end