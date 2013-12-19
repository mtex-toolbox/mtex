function nspec = calc_background(spec,range)
% background of spectra

if nargin == 1, range = 40;end
nspec = zeros(size(spec));

fprintf('calculate background: ');
for i = 1:size(spec,1)	
	
	s  = sort(spec(max(1,i-range):min(i+range,size(spec,1)),:));
	nspec(i,:) = s(fix(size(s,1)/4),:);
	
	progress(i,size(spec,1),155);
	
end
disp('.');
