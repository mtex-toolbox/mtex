function [S2G, W, M2] = quadratureS2Grid(M, varargin)
%
% Syntax
%   [S2G, W, M2] = quadratureS2Grid(M) quadrature grid of type gauss
%   [S2G, W, M2] = quadratureS2Grid(M, 'chebyshev') quadrature grid of type chebyshev
%


persistent S2G_p;
persistent W_p;
persistent M2_p;

if check_option(varargin, 'gauss')
  path = fullfile(mtexDataPath,'quadratureS2Grid_gauss');
else
  path = fullfile(mtexDataPath,'quadratureS2Grid_chebyshev');
end
files = dir( fullfile(path,'*') );
tmp = {files.name}';
tmp = char(tmp);
tmp = mat2cell(tmp(:, 2:5), ones(length(tmp), 1));
tmp = str2double(tmp);
tmp2 = (tmp >= M);
index = find(tmp2, 1);
if isempty(index)
  index = length(tmp);
  warning('M is too large, instead we are giving you the largest quadrature grid we got.');
end

M2 = tmp(index);

if ~isempty(M2_p) && M2_p == M2
  S2G = S2G_p;
  W = W_p;
  M2 = M2_p;

else

  data = load([path, filesep, files(index).name]);
  S2G = vector3d('polar', data(:, 1), data(:, 2));

  if check_option(varargin, 'gauss')
    W = data(:, 3);
  else
    W = 4*pi/size(data, 1) .* ones(size(S2G));
  end
  
  % store the data
  S2G_p = S2G;
  W_p = W;
  M2_p = M2;
    
end

end
