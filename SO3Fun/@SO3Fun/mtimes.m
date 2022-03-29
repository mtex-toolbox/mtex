function SO3F = mtimes(SO3F1,SO3F2)
% implements convolution |SO3F1 * SO3F2| and |SO3F1 * alpha|

if isnumeric(SO3F1) || isnumeric(SO3F2)
  SO3F = times(SO3F1,SO3F2);
  return
end

SO3F = conv(SO3F1,SO3F2);

end
