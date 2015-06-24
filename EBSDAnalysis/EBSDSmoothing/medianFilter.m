classdef medianFilter2 < EBSDFilter
  
  properties
    numNeighbours % number of neigbours to consider (default 1)
  end
  
  methods

    function F = medianFilter2(varargin)
      %
      
      F.numNeighbours = get_option(varargin,'neighbours',1);
            
    end
    
    function q = smooth(F,q)
      
      % some shortcuts
      nn = F.numNeighbours;
      dn = 1+2*nn;
      
      % the mean distance from every candiate to all others
      meanDist = zeros([size(q),2*F.numNeighbours+1,2*F.numNeighbours+1]);
      
      % make q a bit larger
      q = [nanquaternion(F.numNeighbours,size(q,2)+2*F.numNeighbours);...
        [nanquaternion(size(q,1),F.numNeighbours),...
        q,nanquaternion(size(q,1),F.numNeighbours)];...
        nanquaternion(F.numNeighbours,size(q,2)+2*F.numNeighbours)];

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
      [~,id] = min(meanDist,[],3);

      [i,j] = ind2sub(size(qq),1:length(qq));
      [ii,jj] = ind2sub([2*F.numNeighbours+1 2*F.numNeighbours+1],id);

      ii(isnan(q.a(1+nn:end-nn,1+nn:end-nn))) = nn+1;
      jj(isnan(q.a(1+nn:end-nn,1+nn:end-nn))) = nn+1;
      ind = sub2ind(size(q),i(:)+ii(:)-1,j(:)+jj(:)-1);

      % switch to median
      q = q(ind);
      
    end
  end
end