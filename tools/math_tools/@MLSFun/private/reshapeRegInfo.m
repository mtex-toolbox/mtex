function info = reshapeRegInfo(info,dimensions)
% diagnostics in the shape of the evaluation points

for name = fieldnames(info).'
  if numel(info.(name{1})) == prod(dimensions)
    info.(name{1}) = reshape(info.(name{1}),dimensions);
  end
end

end
