function T = logm(T)
% log of a tensor
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

    for l = 1:numel(T)
      T.M(:,:,l) = expm(T.M(:,:,l));
    end
  case 3

  case 4

    % check for symmetry

    % convert to a matrix
    M = tensor42(T.M,T.doubleConvention);

    % exponential of the matrix
    for l = 1:numel(T)
      M(:,:,l) = expm(M(:,:,l));
    end

    %
    T.doubleConvention = ~T.doubleConvention;
    
    % convert to back a 4 rank tensor
    T.M = tensor24(M,T.doubleConvention);
end

% change the name
if hasProperty(T,'name')
  name = get(T,'name');
  T = set(T,'name',['exp ' name]);
  
end

% change the unit
if hasProperty(T,'unit')
  T = set(T,'unit',['exp' get(T,'unit')]);
end
