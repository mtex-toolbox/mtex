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
  if any(strfind(name,'stiffness'))
    T = set(T,'name',strrep(name,'stiffness','compliance'));
  elseif any(strfind(name,'compliance'))
    T = set(T,'name',strrep(name,'compliance','stiffness'));
  elseif any(strfind(name,'inverse'))
    T = set(T,'name',strrep(name,'inverse ',''));
  else
    T = set(T,'name',['inverse ' name]);
  end
end

% change the unit
if hasProperty(T,'unit')
  unit = get(T,'unit');
  slash = strfind(unit,'/');
  if ~isempty(slash)
    a = strtrim(strrep(unit(1:slash-1),'1',''));
    b = strtrim(unit(slash+1:end));
    if isempty(a)
      unit = b;
    else
      unit = [b ' / ' a];
    end    
  else
    unit = ['1 / ' strtrim(unit)];
  end
  T = set(T,'unit',unit);
end
