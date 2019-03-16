function cS = fitArea(cS,faceArea)
% change habitus of crystal shape to fit given faceAreas
% 
% Syntax
%
%   cS = fitArea(cS,faceArea)
%
% Input
%  cS - @crystalShape
%  faceArea - list of desired face areas
%
% Output
%  cS - @crystalShape
%

% we are going to specify the distance of faces to the origin directly
N = cS.N(:);
if cS.habitus >0
  cS.N = N ./ ((abs(N.h) * cS.extension(1)).^cS.habitus + ...
    (abs(N.k) * cS.extension(2)).^cS.habitus + ...
    (abs(N.l) * cS.extension(3)).^cS.habitus).^(1/cS.habitus);
  cS.habitus = 0; 
end
N = N.normalize;

% normalize to area
fA = reshape(cS.faceArea,[],length(cS.N)); fA = fA(1,:);

f = sum((fA(1,:) - faceArea(:).').^2)

%l = fminsearch(@fit,ones(length(N),1));
%l = fmincon(@fit,ones(length(N),1),[],[],[],[],0.1*ones(size(N)),10*ones(size(N)));

cS.N = l .* N;
cS = cS.update;

  %function f = fit(l)
    
    
  %  cS.N = l(:) .* cS.N(:);
  %  cS = cS.update;
  %  try
  %    fA = reshape(cS.faceArea,[],length(cS.N));
  %    f = sum((fA(1,:) - faceArea(:).').^2)
  %  catch
  %    f = 100;
  %  end
   s     
  %end


end