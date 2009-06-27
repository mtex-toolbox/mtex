function l = GridLength(N)
% totalsize of SO3Grids

l = zeros(1,length(N)); %preallocate
for i = 1:length(N)
  l(i) = numel(N(i).Grid); 
end
