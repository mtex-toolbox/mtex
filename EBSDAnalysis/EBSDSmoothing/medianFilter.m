classdef medianFilter < EBSDFilter
  
  properties
    numNeighbours % number of neigbours to consider (default 1)
  end
  
  methods

    function F = medianFilter(varargin)
      %
      
      F.numNeighbours = get_option(varargin,'neighbours',1);
      
      addlistener(F,'isHex','PostSet',@check);
            
      function check(varargin)
        if F.isHex
          warning(['Hexagonal grids are not yet fully supportet for the medianFilter. ' ...
            'It might give reasonable results anyway']);
        end
      end
      
    end
    
    
    function ori = smooth(F,ori,quality)

      ori(quality==0) = nan;
      
      % this projects to the fundamental region around the mean
      [~,ori] = mean(ori);
      
      % make verything quaternion
      q = quaternion(ori);
      
      % some shortcuts
      nn = F.numNeighbours;
      dn = 1+2*nn;
      
      % the mean distance from every candiate to all others
      meanDist = zeros([size(q),2*F.numNeighbours+1,2*F.numNeighbours+1]);
      
      % make q a bit larger
      q = [quaternion.nan(F.numNeighbours,size(q,2)+2*F.numNeighbours);...
        [quaternion.nan(size(q,1),F.numNeighbours),...
        q,quaternion.nan(size(q,1),F.numNeighbours)];...
        quaternion.nan(F.numNeighbours,size(q,2)+2*F.numNeighbours)];

      % compute for any candiate the mean distance to all other points
      % the first two loops are for the candidate
      for i1 = 1:dn
        for j1 = 1:dn
          
          % the candidate
          qq = q(i1+(0:end-dn),j1+(0:end-dn));
          count = zeros(size(qq));
          
          % compute the distance from the candidate to all other candidates          
          for i2 = 1:dn
            for j2 = 1:dn
              
              omega = angle(qq,q(i2+(0:end-dn),j2+(0:end-dn)));          
              [meanDist(:,:,i1,j1),count] = nanplus(meanDist(:,:,i1,j1),omega,count);
              
            end
          end
          
          meanDist(:,:,i1,j1) = meanDist(:,:,i1,j1) ./ count;
                  
        end
      end

      % find median
      meanDist = reshape(meanDist,[size(qq),(2*F.numNeighbours+1)^2,]);
      [mm,id] = min(meanDist,[],3);

      [i,j] = ind2sub(size(qq),1:length(qq));
      [ii,jj] = ind2sub([2*F.numNeighbours+1 2*F.numNeighbours+1],id);

      % in regions where everything is nan take simply the center point
      % we may later weaken this to allow inpainting
      ii(isnan(mm)) = nn+1;
      jj(isnan(mm)) = nn+1;
      
      % compute the final indece to the median
      ind = sub2ind(size(q),i(:)+ii(:)-1,j(:)+jj(:)-1);

      % switch to median
      ori(1:length(ori)) = q(ind);
      
    end
  end
end