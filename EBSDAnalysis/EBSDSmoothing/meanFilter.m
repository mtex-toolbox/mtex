classdef meanFilter2 < EBSDFilter
  % implements a convolution filter for quaternion
  
  properties
    weights
  end
  
  methods

    function F = meanFilter2(varargin)      
      F.weights = get_option(varargin,'weights',ones(3));
      
      %[x,y] = meshgrid(-2:2)
      %A = exp(-(x.^2+y.^2)/10)
    end
    
    function plot(F)
      imagesc(F.weights)
    end
    
    function q = smooth(F,q)
      
      % prepare the result
      tqMean = zeros([size(q),3]);
      
      nrow = size(F.weights,1)-1;
      drowU = fix(nrow/2);
      drowL = nrow - drowU;
      ncol = size(F.weights,2)-1;
      dcolL = fix(ncol/2);
      dcolR = ncol - dcolL;
            
      % make q a bit larger
      q = [nanquaternion(drowU,size(q,2)+ncol);...
        [nanquaternion(size(q,1),dcolL),...
        q,nanquaternion(size(q,1),dcolR)];...
        nanquaternion(drowL,size(q,2)+ncol)];

      % map quaternions into tangential space
      tq = reshape(log(q),[size(q),3]);
      count = zeros(size(tqMean));
      
      % take the mean
      for i = 1:nrow+1
        for j = 1:ncol+1      
          [tqMean,count] = nanplus(tqMean, ...
          tq((1:end-nrow)+i-1,(1:end-ncol)+j-1,:),count,F.weights(i,j));        
        end
      end
             
      tqMean = reshape(tqMean ./ count,[],3);
      % map back to orientation space
      q = reshape(expquat(tqMean),size(q) - [ncol,nrow]);
      
    end
  end
end