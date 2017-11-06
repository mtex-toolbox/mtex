function [S2G, W] = quadratureS2Grid(type, M)
%
% [S2G, W] = get_quadrature_grid(type, m)
%

path = mfilename('fullpath');
if strcmp(type, 'gauss')
	path = [mtex_path '/data/quadratureS2Grid_gauss/'];
elseif strcmp(type, 'chebyshev')
	path = [mtex_path '/data/quadratureS2Grid_chebyshev/'];
else
	error('wrong quadrature grid type');
	return;
end
files = dir( fullfile(path,'*') );
tmp = {files.name}';
tmp = char(tmp);
tmp = mat2cell(tmp(:, 2:5), ones(length(tmp), 1));
tmp = str2double(tmp);
tmp2 = (tmp >= M);
index = find(tmp2, 1);
if isempty(index)
	error('M is too large');
	return;
end

data = load([path, files(index).name]);

rhGrid = repmat(S1Grid([], -pi, pi), 1, size(data, 1));
for ii = 1:size(data, 1)
	rhGrid(ii).points = data(ii, 2);
end

S2G = S2Grid(data(:, 1), rhGrid);
if strcmp(type, 'gauss')
	W = data(:, 3);
else
	W = 4*pi/size(data, 1);
end

end
