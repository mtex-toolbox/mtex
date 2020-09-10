function y = vectorize(E)
% write an embdding as a vector (get back by tensorize)
%
% Syntax
%   y = vectorize(E)
%
% Input
%   E - @embedding
%  
%  
% Output
%   y - vector of double
%
size = E.size;
switch E.CS.Laue.id
    
        case 2 % C1
            y(1,:,:)= reshape(E.u{1}.x,size(1),[]);
            y(2,:,:)= reshape(E.u{1}.y,size(1),[]);
            y(3,:,:)= reshape(E.u{1}.z,size(1),[]);
            y(4,:,:)= reshape(E.u{2}.x,size(1),[]);
            y(5,:,:)= reshape(E.u{2}.y,size(1),[]);
            y(6,:,:)= reshape(E.u{2}.z,size(1),[]);
            y(7,:,:)= reshape(E.u{3}.x,size(1),[]);
            y(8,:,:)= reshape(E.u{3}.y,size(1),[]);
            y(9,:,:)= reshape(E.u{3}.z,size(1),[]);
        
        case {5,8,11} % C2 
            dim2{1}=[1 1];
            dim2{2}=[1 2];
        	dim2{3}=[1 3];
            dim2{4}=[2 2];
            dim2{5}=[2 3];
            y(1,:,:)= reshape(E.u{1}.x,size(1),[]);
            y(2,:,:)= reshape(E.u{1}.y,size(1),[]);
            y(3,:,:)= reshape(E.u{1}.z,size(1),[]);
            for k=1:5
                 y(3+k,:,:)= reshape(E.u{2}.M(dim2{k}(1),dim2{k}(2),:,:),size(1),[]);
                 y(8+k,:,:)= reshape(E.u{3}.M(dim2{k}(1),dim2{k}(2),:,:),size(1),[]);
            end
      
        case 16 % D2 
            dim2{1}=[1 1];
            dim2{2}=[1 2];
        	dim2{3}=[1 3];
            dim2{4}=[2 2];
            dim2{5}=[2 3];
            for k=1:5
                 y(k,:,:)= reshape(E.u{1}.M(dim2{k}(1),dim2{k}(2),:,:),size(1),[]);
                 y(5+k,:,:)= reshape(E.u{2}.M(dim2{k}(1),dim2{k}(2),:,:),size(1),[]);
            end
            
         
        case 18 % C3 
        dim2{1}=[1 1 2];
        dim2{2}=[1 1 3];
        dim2{3}=[1 2 2];
        dim2{4}=[1 2 3];
        dim2{5}=[1 3 3];
        dim2{6}=[2 2 3];
        dim2{7}=[2 3 3];
        for k=1:7
                 y(k,:,:)= reshape(E.u{1}.M(dim2{k}(1),dim2{k}(2),dim2{k}(3),:,:),size(1),[]);
        end
        y(8,:,:)= reshape(E.u{2}.x,size(1),[]);
        y(9,:,:)= reshape(E.u{2}.y,size(1),[]);
        y(10,:,:)= reshape(E.u{2}.z,size(1),[]);
                               
        case {21,24} % D3  
        dim2{1}=[1 1 2];
        dim2{2}=[1 1 3];
        dim2{3}=[1 2 2];
        dim2{4}=[1 2 3];
        dim2{5}=[1 3 3];
        dim2{6}=[2 2 3];
        dim2{7}=[2 3 3];  
        for k=1:7
            y(k,:,:)= reshape(E.u{1}.M(dim2{k}(1),dim2{k}(2),dim2{k}(3),:,:),size(1),[]);
        end
            dim2{1}=[1 1];
            dim2{2}=[1 2];
        	dim2{3}=[1 3];
            dim2{4}=[2 2];
            dim2{5}=[2 3];
        for k=1:5
            y(7+k,:,:)= reshape(E.u{2}.M(dim2{k}(1),dim2{k}(2),:,:),size(1),[]);
        end  
        

        case 27 % C4 
            dim4 = unique(combnk([1 1 1 1 2 2 2 2 3 3 3 3],4),'rows');
        for k=1:14
            y(k,:,:)= reshape(E.u{1}.M(dim4(k,1),dim4(k,2),dim4(k,3),dim4(k,4),:,:),size(1),[]);
        end  
            
        y(15,:,:)= reshape(E.u{2}.x,size(1),[]);
        y(16,:,:)= reshape(E.u{2}.y,size(1),[]);
        y(17,:,:)= reshape(E.u{2}.z,size(1),[]);
        
            
        case 32 % D4 
            dim4 = unique(combnk([1 1 1 1 2 2 2 2 3 3 3 3],4),'rows');
        for k=1:14
            y(k,:,:)= reshape(E.u{1}.M(dim4(k,1),dim4(k,2),dim4(k,3),dim4(k,4),:,:),size(1),[]);
        end  
            
            
          
        case 35 % C6 
          dim6 = unique(combnk([1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3],6),'rows');
          for k=1:27
            y(k,:,:)= reshape(E.u{1}.M(dim6(k,1),dim6(k,2),dim6(k,3),dim6(k,4),dim6(k,5),dim6(k,6),:,:),size(1),[]);
          end
            y(28,:,:)= reshape(E.u{2}.x,size(1),[]);
            y(29,:,:)= reshape(E.u{2}.y,size(1),[]);
            y(30,:,:)= reshape(E.u{2}.z,size(1),[]);
            
        case 40 % D6 
          dim6 = unique(combnk([1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3],6),'rows');
          for k=1:27
            y(k,:,:)= reshape(E.u{1}.M(dim6(k,1),dim6(k,2),dim6(k,3),dim6(k,4),dim6(k,5),dim6(k,6),:,:),size(1),[]);
          end
          
        case 42 % T
            
                 y(1,:,:)= reshape(E.u{1}.M(1,1,2,:,:),size(1),[]);
                 y(2,:,:)= reshape(E.u{1}.M(1,1,3,:,:),size(1),[]);
                 y(3,:,:)= reshape(E.u{1}.M(1,2,2,:,:),size(1),[]);
                 y(4,:,:)= reshape(E.u{1}.M(1,2,3,:,:),size(1),[]);
                 y(5,:,:)= reshape(E.u{1}.M(1,3,3,:,:),size(1),[]);
                 y(6,:,:)= reshape(E.u{1}.M(2,2,3,:,:),size(1),[]);
                 y(7,:,:)= reshape(E.u{1}.M(2,3,3,:,:),size(1),[]);
            

        case 45 % O 
            
        %dim = [1 2 3 5 6 9 14 15 18 27 41 42 45 54 81];
        dim = [2 3 5 9 14 27 42 45 54 ];
        dim2{1}=[1 1 1 2];
        dim2{2}=[1 1 1 3];
        dim2{3}=[1 1 2 2];
        dim2{4}=[1 1 3 3];
        dim2{5}=[1 2 2 2];
        dim2{6}=[1 3 3 3];
        dim2{7}=[2 2 2 3];
        dim2{8}=[2 2 3 3];
        dim2{9}=[2 3 3 3];  
            %         dim2{1}=[1 1 1 1]; 
            %         dim2{2}=[1 1 1 2];
            %         dim2{3}=[1 1 1 3];
            %         dim2{4}=[1 1 2 2];
            %         dim2{5}=[1 1 2 3];
            %         dim2{6}=[1 1 3 3];
            %         dim2{7}=[1 2 2 2];
            %         dim2{8}=[1 2 2 3];
            %         dim2{9}=[1 2 3 3];
            %         dim2{10}=[1 3 3 3 ];
            %         dim2{11}=[2 2 2 2];
            %         dim2{12}=[2 2 2 3];
            %         dim2{13}=[2 2 3 3];
            %         dim2{14}=[2 3 3 3];
            %         dim2{15}=[3 3 3 3];
   
for k=1:9
y(k,:,:)= reshape(E.u{1,1}.M(dim2{k}(1),dim2{k}(2),dim2{k}(3),dim2{k}(4),:,:),size(1),[]);
end
      
end
end

