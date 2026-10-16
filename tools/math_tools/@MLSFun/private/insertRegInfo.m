function info = insertRegInfo(info,I,infoBatch)
% write the diagnostics of a batch into the rows I

for name = fieldnames(infoBatch).'
  if isfield(info,name{1}), info.(name{1})(I,:) = infoBatch.(name{1}); end
end

end
