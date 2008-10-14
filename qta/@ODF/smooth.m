function odf = smooth(odf,varargin)
% smooth ODF
%
%% Input
%  odf - @ODF
%  res - resolution
%
%% Output
%  odf - smmoothed @ODF
%
%% See also
% loadEBSD_txt, SO3Grid/smooth


for i = 1:length(odf)
  
  if check_option(odf(i),'Fourier') % 
    
    A = get_option(varargin,'Fourier');
    L = min(bandwidth(odf),find(A,1,'last')-1);

    odf(i).c_hat=odf(i).c_hat(1:deg2dim(L+1));
    for l = 0:L
      odf(i).c_hat(deg2dim(l)+1:deg2dim(l+1)) = odf(i).c_hat(deg2dim(l)+1:deg2dim(l+1)) * A(l+1);
    end    

  % smmoth grid - only for superpositions of radialy symmetric functions  
  elseif isa(odf(i).center,'SO3Grid')
    
    res = get_option(varargin,'resolution');
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
  if isa(odf(i).psi,'kernel')
    odf(i).psi = smooth(odf(i).psi,res);
  end
  
end
