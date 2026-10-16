function warnings = mergeWarnings(warnings,other)
% a flag is set when it is set in either struct

for name = fieldnames(warnings).'
  warnings.(name{1}) = warnings.(name{1}) | other.(name{1});
end

end
