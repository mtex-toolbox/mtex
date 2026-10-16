function info = sliceRegInfo(info,I)
% the diagnostics of the rows I

for name = fieldnames(info).'
  info.(name{1}) = info.(name{1})(I,:);
end

end
