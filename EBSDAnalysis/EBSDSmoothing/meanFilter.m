classdef meanFilter < EBSDFilter
  % implements a convolution filter for quaternion
  
  properties
    weights
  end
  
  methods

    function F = meanFilter(varargin)      
      F.weights = get_option(varargin,'weights',ones(3));
      
      %[x,y] = meshgrid(-2:2)
      %A = exp(-(x.^2+y.^2)/10)
    end
    
    function plot(F)
      imagesc(F.weights)
    end
    
    function ori = smooth(F,ori)
      
      % map to mean
      [qmean,q] = mean(ori);
      q = reshape(inv(qmean)*q,size(ori)); %#ok<MINV>
            
      % prepare the result
      tqMean = zeros([size(q),3]);
      
      nrow = size(F.weights,1)-1;
      drowU = fix(nrow/2);
      drowL = nrow - drowU;
      ncol = size(F.weights,2)-1;
      dcolL = fix(ncol/2);
      dcolR = ncol - dcolL;
            
      % make q a bit larger
      q = [quaternion.nan(drowU,size(q,2)+ncol);...
        [quaternion.nan(size(q,1),dcolL),...
        q,quaternion.nan(size(q,1),dcolR)];...
        quaternion.nan(drowL,size(q,2)+ncol)];

      % map quaternions into tangential space
      tq = double(log(q));
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
      q = quaternion(qmean) * reshape(expquat(tqMean),size(q) - [ncol,nrow]);
      ori.a = q.a; ori.b = q.b; ori.c = q.c; ori.d = q.d;
            
    end
  end
end
