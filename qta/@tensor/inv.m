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
    M = tensor42(T.M,T.doubleConvention);
        
    % invert the matrix
    for l = 1:size(M,3)
      M(:,:,l) = inv(M(:,:,l));
    end
        
    %
    T.doubleConvention = ~T.doubleConvention;
    
    % convert to back a 4 rank tensor
    T.M = tensor24(M,T.doubleConvention);
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
