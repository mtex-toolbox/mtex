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
if isOption(T,'name')
  if any(strfind(T.opt.name,'stiffness'))
    T.opt.name = strrep(T.opt.name,'stiffness','compliance');
  elseif any(strfind(T.opt.name,'compliance'))
    T.opt.name = strrep(T.opt.name,'compliance','stiffness');
  elseif any(strfind(T.opt.name,'inverse'))
    T.opt.name = strrep(T.opt.name,'inverse ','');
  else
    T.opt.name = ['inverse ' T.opt.name];
  end
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
