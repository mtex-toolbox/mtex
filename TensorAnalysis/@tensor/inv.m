function T = inv(T)
% inverse of a tensor
%
% Input
%  T - @tensor
%
% Output
%  T - @tensor
%

switch T.rank

  case 1
    
    T.M = 1./T.M;
    
  case 2

    for j = 1:length(T)
      T.M(:,:,j) = inv(T.M(:,:,j));
    end

  case 3

  case 4

    % check for symmetry

    % convert to a matrix
    M = tensor42(T.M,T.doubleConvention);
        
    % invert the matrix
    for l = 1:length(T)
      M(:,:,l) = inv(M(:,:,l));
    end
        
    %
    T.doubleConvention = ~T.doubleConvention;
    
    % convert to back a 4 rank tensor
    T.M = tensor24(M,T.doubleConvention);
end

% change the unit
if isOption(T,'unit')
  slash = strfind(T.opt.unit,'/');
  if ~isempty(slash)
    a = strtrim(strrep(T.opt.unit(1:slash-1),'1',''));
    b = strtrim(T.opt.unit(slash+1:end));
    if isempty(a)
      T.opt.unit = b;
    else
      T.opt.unit = [b ' / ' a];
    end    
  else
    T.opt.unit = ['1 / ' strtrim(T.opt.unit)];
  end  
end
