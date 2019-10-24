function T = expm(T)
% matrix exponential of a tensor
%
% Input
%  T - @tensor
%
% Output
%  T - @tensor
%

switch T.rank

  case 1

  case 2

    for l = 1:length(T)
      T.M(:,:,l) = expm(T.M(:,:,l));
    end
  case 3

  case 4

    % convert to a matrix
    M = tensor42(T.M,2);

    % exponential of the matrix
    for l = 1:length(T)
      M(:,:,l) = expm(M(:,:,l));
    end

    % convert to back a 4 rank tensor
    T.M = tensor24(M,2);
end

