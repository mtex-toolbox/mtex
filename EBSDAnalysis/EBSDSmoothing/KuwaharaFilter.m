classdef KuwaharaFilter < EBSDFilter
  
  properties
    numNeighbours % number of neigbours to consider (default 1)
  end
  
  methods

    function F = KuwaharaFilter(varargin)
      %
      
      F.numNeighbours = get_option(varargin,'neighbours',1);
            
      addlistener(F,'isHex','PostSet',@check);
      function check(varargin)
        if F.isHex
          warning(['Hexagonal grids are not yet fully supportet for the KuwaharaFilter. ' ...
            'It might give reasonable results anyway']);
        end
      end
      
    end
    
    function ori = smooth(F,ori,quality)
      
      ori(quality==0) = nan;
      
      % map to mean
      [qmean,q] = mean(ori);
      q = reshape(inv(qmean)*q,size(ori)); %#ok<MINV>
            
      % prepare the result
      tqMean = nan(length(q),3);
      stdOpt = inf(size(q));
      
      n = F.numNeighbours;
      % make q a bit larger
      q = [quaternion.nan(n,size(q,2)+2*n);...
        [quaternion.nan(size(q,1),n),...
        q,quaternion.nan(size(q,1),n)];...
        quaternion.nan(n,size(q,2)+2*n)];

      % map quaternions into tangential space
      tq = double(log(q));
     
      for d = 0:3
        
        % decide for one of the quadrants
        dir = (1+1i)^(2*d+1);
        xdir = sign(real(dir));
        ydir = sign(imag(dir));
        
        % compute the mean
        meanLocal = zeros([size(ori),3]);
        count = zeros(size(meanLocal));
        
        for i = 0:n
          for j = 0:n
            [meanLocal,count] = nanplus(meanLocal, ...
              tq((1+n:end-n)+i*xdir,(1+n:end-n)+j*ydir,:),count);
          end
        end
        meanLocal = meanLocal ./ count;
                
        % compute variance
        stdLocal = zeros(size(ori));
        for i = 0:n
          for j = 0:n
            stdLocal = nanplus(stdLocal, ...
              sum((meanLocal-tq((1+n:end-n)+i*xdir,(1+n:end-n)+j*ydir,:)).^2,3));
          end
        end
        stdLocal = (stdLocal+eps) ./ max(0,(count(:,:,1)-1));

        % keep mean with smallest variance
        ind = stdLocal < stdOpt;
        ind3 = repmat(ind,[1,1,3]);
        tqMean(ind3) = meanLocal(ind3);
        stdOpt(ind) = stdLocal(ind);
      
      end  
                 
      % map back to orientation space
      q = quaternion(qmean) * reshape(expquat(tqMean),size(ori));
      ori.a = q.a; ori.b = q.b; ori.c = q.c; ori.d = q.d;
      
    end
  end
end