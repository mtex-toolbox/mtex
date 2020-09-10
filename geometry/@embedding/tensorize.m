function E = tensorize(y,cs)
% opposite of vectorize: get the embedding as a tensor from a vector
%
% Syntax
%   E = tensorize(y,cs)
%
% Input
%  y - double
%  cs - @crystalSymmetry
%
% Output
%  E - @embedding
%
dim = size(y);
dim = dim(2:end);
[l,~,weights]= embedding.coefficients(cs);


switch cs.Laue.id
    
        case 2 % C1
            E(dim,1) = embedding.id(cs);
            E.u{1} = reshape(vector3d(y(1:3,:,:)),dim,[]);
            E.u{2} = reshape(vector3d(y(4:6,:,:)),dim,[]);
            E.u{3} = reshape(vector3d(y(7:9,:,:)),dim,[]);
           
        
        case {5,8,11} % C2 
            dim2{1}=[1 1];
            dim2{2}=[1 2];
        	dim2{3}=[1 3];
            dim2{4}=[2 2];
            dim2{5}=[2 3];
            u1 = reshape(vector3d(y(1:3,:,:)),dim,[]);
            
            for k=1:5
                 M2(dim2{k}(1),dim2{k}(2),:,:) = reshape(y(3+k,:,:),1,1,dim);
                 M3(dim2{k}(1),dim2{k}(2),:,:) = reshape(y(8+k,:,:),1,1,dim);
                 M2(3,3,:,:)=zeros(dim,1);
                 M3(3,3,:,:)=zeros(dim,1);
            end
            
            [I1,I2]=ndgrid(1:3);
        P = [I1(:),I2(:)];
        Q = sort(P,2,'ascend');
        for i=0:1:prod(dim)-1
            M2(9*i+sub2ind([3,3],P(:,1),P(:,2))) =M2(9*i+sub2ind([3,3],Q(:,1),Q(:,2)));
            M3(9*i+sub2ind([3,3],P(:,1),P(:,2))) =M3(9*i+sub2ind([3,3],Q(:,1),Q(:,2)));
        end
            M2(3,3,:,:) = reshape(-reshape(M2(1,1,:,:),[1,dim])-reshape(M2(2,2,:,:),[1,dim]),[1,1,dim]);
            M3(3,3,:,:) = reshape(-reshape(M3(1,1,:,:),[1,dim])-reshape(M3(2,2,:,:),[1,dim]),[1,1,dim]);
            
            u2 = tensor(M2,'rank',2);
            u3 = tensor(M3,'rank',2);
            
           
            E = embedding({u1;u2;u3},cs,l);
            E = reshape(E,dim(1),[]);
      
        case 16 % D2 
            dim2{1}=[1 1];
            dim2{2}=[1 2];
        	dim2{3}=[1 3];
            dim2{4}=[2 2];
            dim2{5}=[2 3];
            for k=1:5
                 M1(dim2{k}(1),dim2{k}(2),:,:) = reshape(y(k,:,:),1,1,dim);
                 M2(dim2{k}(1),dim2{k}(2),:,:) = reshape(y(5+k,:,:),1,1,dim);
            end
                 M1(3,3,:,:)=reshape(-y(1,:,:)-y(4,:,:),[1,1,dim]);
                 M2(3,3,:,:)=reshape(-y(9,:,:)-y(6,:,:),[1,1,dim]);
                 M3 = -M2 - M1;
                 
            %symmetrise
            [I1,I2]=ndgrid(1:3);
            P = [I1(:),I2(:)];
            Q = sort(P,2,'ascend');
            for i=0:1:prod(dim)-1
                M1(9*i+sub2ind([3,3],P(:,1),P(:,2))) =M1(9*i+sub2ind([3,3],Q(:,1),Q(:,2)));
                M2(9*i+sub2ind([3,3],P(:,1),P(:,2))) =M2(9*i+sub2ind([3,3],Q(:,1),Q(:,2)));
                M3(9*i+sub2ind([3,3],P(:,1),P(:,2))) =M3(9*i+sub2ind([3,3],Q(:,1),Q(:,2)));
            end
            u1 = tensor(M1,'rank',2);
            u2 = tensor(M2,'rank',2);
            u3 = tensor(M3,'rank',2);
           
            E = embedding({u1;u2;u3},cs,l);
            E = reshape(E,dim(1),[]);
            
            
        case 18 % C3 
            dim3{1}=[1 1 2];
            dim3{2}=[1 1 3];
            dim3{3}=[1 2 2];
            dim3{4}=[1 2 3];
            dim3{5}=[1 3 3];
            dim3{6}=[2 2 3];
            dim3{7}=[2 3 3];
            
            for k=1:7
                  M1(dim3{k}(1),dim3{k}(2),dim3{k}(3),:,:) = reshape(y(k,:,:),1,1,dim);
            end
            M1(1,1,1,:,:)=reshape(-y(3,:,:)-y(5,:,:),[1,1,1,dim]);
            M1(2,2,2,:,:)=reshape(-y(1,:,:)-y(7,:,:),[1,1,1,dim]);
            M1(3,3,3,:,:)=reshape(-y(2,:,:)-y(6,:,:),[1,1,1,dim]);
            %symmetrise
            [I1,I2,I3]=ndgrid(1:3);
            P = [I1(:),I2(:),I3(:)];
            Q = sort(P,2,'ascend');
            for i=0:1:prod(dim)-1
                M1(27*i+sub2ind([3,3,3],P(:,1),P(:,2),P(:,3))) =M1(27*i+sub2ind([3,3,3],Q(:,1),Q(:,2),Q(:,3)));
            end
            u1 = tensor(M1,'rank',3);
            u2 = reshape(vector3d(y(8:10,:,:)),dim,[]);
            E = embedding({u1;u2},cs,l);
            E = reshape(E,dim(1),[]);
            
            
        case {21,24} % D3 
            dim3{1}=[1 1 2];
            dim3{2}=[1 1 3];
            dim3{3}=[1 2 2];
            dim3{4}=[1 2 3];
            dim3{5}=[1 3 3];
            dim3{6}=[2 2 3];
            dim3{7}=[2 3 3];
            
            for k=1:7
                  M1(dim3{k}(1),dim3{k}(2),dim3{k}(3),:,:) = reshape(y(k,:,:),[1,1,1,dim]);
            end
            M1(1,1,1,:,:)=reshape(-y(3,:,:)-y(5,:,:),[1,1,1,dim]);
            M1(2,2,2,:,:)=reshape(-y(1,:,:)-y(7,:,:),[1,1,1,dim]);
            M1(3,3,3,:,:)=reshape(-y(2,:,:)-y(6,:,:),[1,1,1,dim]);
            %symmetrise
            [I1,I2,I3]=ndgrid(1:3);
            P = [I1(:),I2(:),I3(:)];
            Q = sort(P,2,'ascend');
            for i=0:1:prod(dim)-1
                M1(27*i+sub2ind([3,3,3],P(:,1),P(:,2),P(:,3))) =M1(27*i+sub2ind([3,3,3],Q(:,1),Q(:,2),Q(:,3)));
            end
            
            dim2{1}=[1 1];
            dim2{2}=[1 2];
        	dim2{3}=[1 3];
            dim2{4}=[2 2];
            dim2{5}=[2 3];
            for k=1:5
                 M2(dim2{k}(1),dim2{k}(2),:,:) = reshape(y(7+k,:,:),1,1,dim);
            end
                 M2(3,3,:,:)=reshape(-y(8,:,:)-y(11,:,:),[1,1,dim]);
                 
            %symmetrise
            [I1,I2]=ndgrid(1:3);
            P = [I1(:),I2(:)];
            Q = sort(P,2,'ascend');
            for i=0:1:prod(dim)-1
                M2(9*i+sub2ind([3,3],P(:,1),P(:,2))) =M2(9*i+sub2ind([3,3],Q(:,1),Q(:,2)));
            end
            u1 = tensor(M1,'rank',3);
            u2 = tensor(M2,'rank',2);
            
            
            E = embedding({u1;u2},cs,l);
            E = reshape(E,dim(1),[]);
            
      
        case 27 % C4 
            dim4{1}=[1 1 1 1]; 
            dim4{2}=[1 1 1 2];
            dim4{3}=[1 1 1 3];
            dim4{4}=[1 1 2 2];
            dim4{5}=[1 1 2 3];
            dim4{6}=[1 1 3 3];
            dim4{7}=[1 2 2 2];
            dim4{8}=[1 2 2 3];
            dim4{9}=[1 2 3 3];
            dim4{10}=[1 3 3 3 ];
            dim4{11}=[2 2 2 2];
            dim4{12}=[2 2 2 3];
            dim4{13}=[2 2 3 3];
            dim4{14}=[2 3 3 3];
        for k=1:14
            M1(dim4{k}(1),dim4{k}(2),dim4{k}(3),dim4{k}(4),:,:) = reshape(y(k,:,:),1,1,1,1,dim);
        end
            M1(3,3,3,3,:,:) = reshape(-reshape(M1(1,1,1,1,:,:),[1,dim])-reshape(M1(2,2,2,2,:,:),[1,dim])-2*reshape(M1(1,1,2,2,:,:),[1,dim])-2*reshape(M1(1,1,3,3,:,:),[1,dim])-2*reshape(M1(2,2,3,3,:,:),[1,dim]),[1,1,1,1,dim]);
            
        %symmetrise M
            [I1,I2,I3,I4]=ndgrid(1:3);
            P = [I1(:),I2(:),I3(:),I4(:)];
            Q = sort(P,2,'ascend');
            for i=0:1:prod(dim)-1
                M1(81*i+sub2ind([3,3,3,3],P(:,1),P(:,2),P(:,3),P(:,4))) =M1(81*i+sub2ind([3,3,3,3],Q(:,1),Q(:,2),Q(:,3),Q(:,4)));
            end
                
            
            u1 = tensor(M1,'rank',4);
            u2 = reshape(vector3d(y(15:17,:,:)),dim,[]);
            E = embedding({u1;u2},cs,l);
            E = reshape(E,dim(1),[]);
            
            
        case 32 % D4 
            dim4{1}=[1 1 1 1]; 
            dim4{2}=[1 1 1 2];
            dim4{3}=[1 1 1 3];
            dim4{4}=[1 1 2 2];
            dim4{5}=[1 1 2 3];
            dim4{6}=[1 1 3 3];
            dim4{7}=[1 2 2 2];
            dim4{8}=[1 2 2 3];
            dim4{9}=[1 2 3 3];
            dim4{10}=[1 3 3 3 ];
            dim4{11}=[2 2 2 2];
            dim4{12}=[2 2 2 3];
            dim4{13}=[2 2 3 3];
            dim4{14}=[2 3 3 3];
        for k=1:14
            M1(dim4{k}(1),dim4{k}(2),dim4{k}(3),dim4{k}(4),:,:) = reshape(y(k,:,:),1,1,1,1,dim);
        end
            M1(3,3,3,3,:,:) = reshape(-y(1,:,:)-2*y(4,:,:)-2*y(6,:,:)-y(11,:,:)-2*y(13,:,:),1,1,1,1,dim);
            
        %symmetrise M1
            [I1,I2,I3,I4]=ndgrid(1:3);
            P = [I1(:),I2(:),I3(:),I4(:)];
            Q = sort(P,2,'ascend');
            for i=0:1:prod(dim)-1
                M1(81*i+sub2ind([3,3,3,3],P(:,1),P(:,2),P(:,3),P(:,4))) =M1(81*i+sub2ind([3,3,3,3],Q(:,1),Q(:,2),Q(:,3),Q(:,4)));
            end
            
            M2(2,3,:,:) = reshape(-sqrt(2)*y(5,:,:)-sqrt(2)*y(12,:,:)-sqrt(2)*y(14,:,:),1,1,1,1,dim);
            M2(1,3,:,:) = reshape(-sqrt(2)*y(3,:,:)-sqrt(2)*y(8,:,:)-sqrt(2)*y(10,:,:),1,1,1,1,dim);
            M2(1,2,:,:) = reshape(-sqrt(2)*y(2,:,:)-sqrt(2)*y(7,:,:)-sqrt(2)*y(9,:,:),1,1,1,1,dim);
            M2(2,2,:,:) = reshape(-sqrt(2)*y(4,:,:)-sqrt(2)*y(11,:,:)-sqrt(2)*y(13,:,:),1,1,1,1,dim);
            M2(1,3,:,:) = reshape(-sqrt(2)*y(3,:,:)-sqrt(2)*y(8,:,:)-sqrt(2)*y(10,:,:),1,1,1,1,dim);
            M2(3,3,:,:) = reshape(-sqrt(2)*y(6,:,:)-sqrt(2)*y(13,:,:)-sqrt(2)*reshape(M1(3,3,3,3,:,:),[1,dim]),1,1,1,1,dim);
            M2(1,1,:,:) = reshape(-reshape(M2(2,2,:,:),[1,dim])-reshape(M2(3,3,:,:),[1,dim]),1,1,dim);
            
            %symmetrise M2
            [I1,I2]=ndgrid(1:3);
            P = [I1(:),I2(:)];
            Q = sort(P,2,'ascend');
            for i=0:1:prod(dim)-1
                M2(9*i+sub2ind([3,3,3,3],P(:,1),P(:,2))) =M2(9*i+sub2ind([3,3,3,3],Q(:,1),Q(:,2)));
            end
            u1 = tensor(M1,'rank',4);
            u2 =tensor(M2,'rank',2);
            
            E = embedding({u1;u2},cs,l);
            E = reshape(E,dim(1),[]);
        
        case 35 % C6 
          dim6 = unique(combnk([1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3],6),'rows');
      
          for k=1:27
            M1(dim6(k,1),dim6(k,2),dim6(k,3),dim6(k,4),dim6(k,5),dim6(k,6),:,:) = reshape(y(k,:,:),1,1,1,1,1,1,dim);
          end
            M1(3,3,3,3,3,3,:,:) = zeros(1,1,1,1,1,1,dim);
        %symmetrise M1
            [I1,I2,I3,I4,I5,I6]=ndgrid(1:3);
            P = [I1(:),I2(:),I3(:),I4(:),I5(:),I6(:)];
            Q = sort(P,2,'ascend');
            for i=0:1:prod(dim)-1
                M1(3^6*i+sub2ind([3,3,3,3,3,3],P(:,1),P(:,2),P(:,3),P(:,4),P(:,5),P(:,6))) =M1(3^6*i+sub2ind([3,3,3,3,3,3],Q(:,1),Q(:,2),Q(:,3),Q(:,4),Q(:,5),Q(:,6)));
            end
            M1(3,3,3,3,3,3,:,:) = reshape(-reshape(M1(1,1,1,1,1,1,:,:),[1,dim])-reshape(M1(2,2,2,2,2,2,:,:),[1,dim])-3*reshape(M1(1,1,2,2,2,2,:,:),[1,dim])-3*reshape(M1(1,1,3,3,3,3,:,:),[1,dim])-3*reshape(M1(2,2,1,1,1,1,:,:),[1,dim])-3*reshape(M1(2,2,3,3,3,3,:,:),[1,dim])-3*reshape(M1(3,3,1,1,1,1,:,:),[1,dim])-3*reshape(M1(3,3,2,2,2,2,:,:),[1,dim])-6*reshape(M1(1,1,2,2,3,3,:,:),[1,dim]),[1,1,1,1,dim]);    
            
            
            u1 = tensor(M1,'rank',6);
            u2 = reshape(vector3d(y(28:30,:,:)),dim,[]);
            E = embedding({u1;u2},cs,l);
            E = reshape(E,dim(1),[]);
            
          
        case 40 % D6 
            dim6 = unique(combnk([1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3],6),'rows');
                dimM = [1 1 1 1;
                  2 2 2 2;
                  3 3 3 3;
                  1 1 2 2;
                  1 1 3 3;
                  2 2 3 3];
          for k=1:27
            M1(dim6(k,1),dim6(k,2),dim6(k,3),dim6(k,4),dim6(k,5),dim6(k,6),:,:) = reshape(y(k,:,:),1,1,1,1,1,1,dim);
          end
            M1(3,3,3,3,3,3,:,:) = zeros(1,1,1,1,1,1,dim);
        %symmetrise M1
            [I1,I2,I3,I4,I5,I6]=ndgrid(1:3);
            P = [I1(:),I2(:),I3(:),I4(:),I5(:),I6(:)];
            Q = sort(P,2,'ascend');
            for i=0:1:prod(dim)-1
                M1(3^6*i+sub2ind([3,3,3,3,3,3],P(:,1),P(:,2),P(:,3),P(:,4),P(:,5),P(:,6))) =M1(3^6*i+sub2ind([3,3,3,3,3,3],Q(:,1),Q(:,2),Q(:,3),Q(:,4),Q(:,5),Q(:,6)));
            end
            M1(3,3,3,3,3,3,:,:) = reshape(-reshape(M1(1,1,1,1,1,1,:,:),[1,dim])-reshape(M1(2,2,2,2,2,2,:,:),[1,dim])-3*reshape(M1(1,1,2,2,2,2,:,:),[1,dim])-3*reshape(M1(1,1,3,3,3,3,:,:),[1,dim])-3*reshape(M1(2,2,1,1,1,1,:,:),[1,dim])-3*reshape(M1(2,2,3,3,3,3,:,:),[1,dim])-3*reshape(M1(3,3,1,1,1,1,:,:),[1,dim])-3*reshape(M1(3,3,2,2,2,2,:,:),[1,dim])-6*reshape(M1(1,1,2,2,3,3,:,:),[1,dim]),[1,1,1,1,dim]);    
            
            M2 = zeros(3,3,dim);
            for i1 =1:1:3
                for i2 =1:1:3
                    for k =1:1:3
                        s = sort([i1,i2,dimM(k,:)]) ; 
                        t = sort([i1,i2,dimM(3+k,:)]);
                        M2(i1,i2,:,:) = M2(i1,i2,:,:)-sqrt(3)/4*reshape(reshape(M1(s(1),s(2),s(3),s(4),s(5),s(6),:,:),[1,dim]),[1,1,dim]);
                        M2(i1,i2,:,:) = M2(i1,i2,:,:)-sqrt(3)/2*reshape(reshape(M1(t(1),t(2),t(3),t(4),t(5),t(6),:,:),[1,dim]),[1,1,dim]);
                    end
                end
            end
            
            M2(3,3,:,:) = -reshape(reshape(M2(2,2,:,:),[1,dim])+reshape(M2(1,1,:,:),[1,dim]),[1,1,dim]);
            
            u1 = tensor(M1,'rank',6);
            u2 = tensor(M1,'rank',2);
            E = embedding({u1;u2},cs,l);
            E = reshape(E,dim(1),[]);
            
            
        case 42 % T
            
            dim3{1}=[1 1 2];
            dim3{2}=[1 1 3];
            dim3{3}=[1 2 2];
            dim3{4}=[1 2 3];
            dim3{5}=[1 3 3];
            dim3{6}=[2 2 3];
            dim3{7}=[2 3 3];
            
            for k=1:7
                  M(dim3{k}(1),dim3{k}(2),dim3{k}(3),:,:) = reshape(y(k,:,:),[1,1,1,dim]);
            end
            M(1,1,1,:,:)=reshape(-y(3,:,:)-y(5,:,:),[1,1,1,dim]);
            M(2,2,2,:,:)=reshape(-y(1,:,:)-y(7,:,:),[1,1,1,dim]);
            M(3,3,3,:,:)=reshape(-y(2,:,:)-y(6,:,:),[1,1,1,dim]);
            
            %symmetrise
            [I1,I2,I3]=ndgrid(1:3);
            P = [I1(:),I2(:),I3(:)];
            Q = sort(P,2,'ascend');
            for i=0:1:prod(dim)-1
                M(27*i+sub2ind([3,3,3],P(:,1),P(:,2),P(:,3))) =M(27*i+sub2ind([3,3,3],Q(:,1),Q(:,2),Q(:,3)));
            end
             u = tensor(M,'rank',3);
   
            E = embedding({u},cs,l);
            E = reshape(E,dim(1),[]);
            
        case 45 % O 
            
        %dim = [1 2 3 5 6 9 14 15 18 27 41 42 45 54 81];
        %dim = [2 3 5 9 14 27 42 45 54 ];
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
   M =zeros([3,3,3,3,dim]);
    for k=1:9
        M(dim2{k}(1),dim2{k}(2),dim2{k}(3),dim2{k}(4),:,:) = reshape(y(k,:,:),[1,1,1,1,dim]);
    end
        M(1 ,1, 2, 3,:,:) = reshape(-y(7,:,:)-y(9,:,:),[1,1,1,1,dim]);
        M(1, 2, 2, 3,:,:) = reshape(-y(2,:,:)-y(6,:,:),[1,1,1,1,dim]); 
        M(1, 2, 3, 3,:,:) = reshape(-y(1,:,:)-y(5,:,:),[1,1,1,1,dim]);
        M(1, 1, 1, 1,:,:) = reshape(-y(3,:,:)-y(4,:,:),[1,1,1,1,dim]);
        M(3, 3, 3, 3,:,:) = reshape(-y(8,:,:)+y(3,:,:)+reshape(M(1, 1, 1, 1,:,:),[1,dim]),[1,1,1,1,dim]);
        M(2, 2, 2, 2,:,:) = reshape(-y(8,:,:)+y(4,:,:)+reshape(M(1, 1, 1, 1,:,:),[1,dim]),[1,1,1,1,dim]);
    
        %symmetrise M
        [I1,I2,I3,I4]=ndgrid(1:3);
        P = [I1(:),I2(:),I3(:),I4(:)];
        Q = sort(P,2,'ascend');
        for i=0:1:prod(dim)-1
            M(81*i+sub2ind([3,3,3,3],P(:,1),P(:,2),P(:,3),P(:,4))) =M(81*i+sub2ind([3,3,3,3],Q(:,1),Q(:,2),Q(:,3),Q(:,4)));
        end
        u = tensor(M,'rank',4);
   
        E = embedding({u},cs,l);
        E = reshape(E,dim(1),[]);
end


