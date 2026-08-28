function dispLine(s)
% display symmetry as a one-liner

if s.id > 2
  disp([' specimen symmetry: ',char(s,'verbose')]);
end

end