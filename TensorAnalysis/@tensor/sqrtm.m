function T = sqrtm(T)
% matrix exponential of a tensor
%
% Input
%  T - @tensor
%
% Output
%  T - @tensor
%

switch T.rank

  case 2

    for l = 1:length(T)
      T.M(:,:,l) = sqrtm(T.M(:,:,l));
    end
   
  otherwise
    
    error('Not implemented')
    
end

% change the name
%if isOption(T,'name'), T.opt.name = ['exp ' T.opt.name]; end

% change the unit
%if isOption(T,'unit'), T.opt.unit = ['exp ' T.opt.unit]; end
