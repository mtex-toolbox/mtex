function T = inv(T)
% inverse of a tensor
%
%% Input
%  T - @tensor
%
%% Output
%  T - @tensor
%

switch T.rank

  case 1

  case 2

    T.M = inv(T.M);

  case 3

  case 4

    % check for symmetry

    % convert to a matrix
    M = tensor42(T.M);

    % invert the matrix
    M = inv(M);

    % make some corrections
    w = 1./(1+((1:6)>3));
    w = w.' * w;
    M = M .* w;

    % convert to back a 4 rank tensor
    T.M = tensor24(M);
end

% change the name
if hasProperty(T,'name')
  name = get(T,'name');
  if findstr(name,'stiffness')
    T = set(T,'name',strrep(name,'stiffness','compliance'));
  else
    T = set(T,'name',['inverse ' name]);
  end
end

% change the unit
if hasProperty(T,'unit')
  T = set(T,'unit',['1/' get(T,'unit')]);
end
