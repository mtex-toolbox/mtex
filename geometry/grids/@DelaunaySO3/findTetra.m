 function [tetra,bario,iter] = findTetra(DSO3,ori)
 % find tetrahegon
 %
 % Input
 %  DSO3 - @DelaunaySO3
 %  ori  - @orientation
 %
 % Output
 %  tetra - indice of the tetrahegon
 %  bario - bariocentric coordinates
 %
 
 ori = orientation(ori,DSO3.CS,DSO3.SS);
 
 % look up table
 if ~isempty(DSO3.lookup)
   [max_phi1,max_Phi,max_phi2] = fundamentalRegionEuler(DSO3.CS,DSO3.SS);
   %ori = ori.project2FundamentalRegion;
   
   if max_Phi<pi
     [axes,~] = DSO3.CS.getMinAxes;
     ia = find(isnull(dot(axes,zvector)),1,'first');
     [~,Phi,~] = Euler(ori);
     ori(Phi > pi/2) = ori(Phi > pi/2) * orientation.byAxisAngle(axes(ia),pi,DSO3.CS,DSO3.CS);     
   end
   
   [phi1,Phi,phi2] = Euler(ori);
   s = size(DSO3.lookup)-1;
   iphi1 = 1+round(mod(phi1./max_phi1,1) * s(1));
   iPhi  = 1+round(Phi./max_Phi * s(2));
   iphi2 = 1+round(mod(phi2./max_phi2,1) * s(3));
   
   tetra = DSO3.lookup(sub2ind(size(DSO3.lookup),iphi1,iPhi,iphi2));
 else
   ind = find(DSO3,ori);
   I = sparse(repmat((1:size(DSO3.tetra,1))',1,4),double(DSO3.tetra),1);
   [~,tetra] = max(I(:,ind));
 end
  
 % initalize
 inside = false(size(ori));
 bario = zeros(length(ori),4);
 
 iter = zeros(size(ori));
 
 tic;
 % while not all found
 while any(~inside(:))
   
   %disp([int2str(nnz(~inside)) '/' int2str(numel(inside))]) 
   %toc
   iter(~inside) = iter(~inside) + 1;
   ind = find(~inside);
   
   % compute bariocentric coordiantes
   bario(~inside,:) = calcBario(DSO3,ori(~inside),tetra(~inside));   
   
   % check inside
   [neg,side] = min(bario(~inside,:),[],2);   
   
   %angle(mean(DSO3.subsref(DSO3.tetra(tetra,:))),ori)./degree
   %angle(DSO3.subsref(DSO3.tetra(tetra,:)),ori)./degree
   %angle(DSO3.subsref(DSO3.tetra(DSO3.tetraNeighbour(tetra,side),:)),ori)./degree
   %angle(mean(DSO3.subsref(DSO3.tetra(DSO3.tetraNeighbour(tetra,side),:))),ori)./degree
   
   % distances
   %[~,side] = max(d);
      
   % for those outside update tetra
   t = double(tetra(ind(neg<0)));
   s = side(neg<0);
   tetra(ind(neg<0)) = DSO3.tetraNeighbour(...
     sub2ind(size(DSO3.tetraNeighbour),t(:),s(:)));
      
   % update inside
   inside(~inside) = neg >=0;   
   
   %if nnz(~inside) <= 5, find(~inside), end
   
 end
 
 end
    
