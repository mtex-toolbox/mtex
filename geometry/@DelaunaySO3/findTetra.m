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
 
 % look up table TODO!!
 ind = find(DSO3,ori); 
 [~,tetra] = max(DSO3.I_oriTetra(:,ind))
  
 % initalize
 inside = false(size(ori));
 bario = zeros(length(ori),4);
 
 iter = zeros(size(ori));
 
 % while not all found
 while any(~inside(:))
   
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
   tetra(ind(neg<0)) = DSO3.tetraNeighbour(...
     sub2ind(size(DSO3.tetraNeighbour),tetra(ind(neg<0)),side(neg<0).'));
      
   % update inside
   inside(~inside) = neg >=0;
   
 end
 
 end
    
