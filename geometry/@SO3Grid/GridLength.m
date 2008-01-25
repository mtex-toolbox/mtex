function [l,ll] = GridLength(N)
% totalsize of SO3Grids

for i = 1:length(N)
    l(i) = numel(N(i).Grid); %#ok<AGROW>
end

if check_option(N,'indexed')  
  for i = 1:length(N)
    ll(i) = sum(GridLength(N(i).gamma)); %#ok<AGROW>
  end  
else  
  ll = l;
end
