function [S2G, W] = quadratureS2Grid(M, varargin)
%
% [S2G, W] = get_quadrature_grid(m) quadrature grid of type gauss
% [S2G, W] = get_quadrature_grid(m, 'chebyshev') quadrature grid of thype chebyshev
%

path = mfilename('fullpath');
if check_option(varargin, 'gauss')
	path = [mtex_path '/data/quadratureS2Grid_gauss/'];
else
	path = [mtex_path '/data/quadratureS2Grid_chebyshev/'];
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
if check_option(varargin, 'gauss')
	W = data(:, 3);
else
	W = 4*pi/size(data, 1);
end

end
