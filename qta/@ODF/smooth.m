function sodf = smooth(odf,res)
% smooth ODF
%
%% Input
%  odf - @ODF
%  res - resolution
%
%% Output
%  sodf - smmoothed @ODF
%
%% See also
% loadEBSD_txt, SO3Grid/smooth


for i = 1:legnth(odf)
  
  % smmoth grid - only for superpositions of radialy symmetric functions
  if isa(odf(i).center,'SO3Grid')
    
    % smooth grid
    [odf(i).center,order] = smooth(idf(i).center,res);
    odf(i).c = odf(i).c(order);
    
    % join equivalent orientations
    j = 2;
    while j <= length(odf(i).c)
      
      if isequal(odf(i).center(j),odf(i).center(j-1))
        odf(i).center(j) = [];
        odf(i).c(j-1) = odf(i).c(j-1)+odf(i).c(j);
        odf(i).c(j) = [];
      end
    end
  end
  
  % smooth kernel  
  if isa(odf(i).kernel,'kernel')
    odf(i).kernel = smooth(odf(i).kernel,res);
  end
  
end

sodf = odf;
