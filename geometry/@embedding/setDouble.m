function obj = setDouble(obj,d)

d = reshape(d,[],obj.dim);
s = size(obj);

ind4 = [1 28 55 37 64 73 40 67 76 79 41 68 77 80];     
ind43 = ind4([2 3 4 6 7 10 12 13 14]);



switch obj.CS.Laue.id
    
  case 2 % C1
    
    obj.u{1} = vector3d(d(:,1:3).').';
    obj.u{2} = vector3d(d(:,4:6).').';
    obj.u{3} = vector3d(d(:,7:9).').';
    
  case {5,8,11} % C2
    
    obj.u{1} = vector3d(d(:,1:3).').';

    obj.u{2}.M = fillT2(d(:,4:8));  obj.u{2} = obj.u{2}.sym;
    
    obj.u{3}.M = fillT2(d(:,9:13)); obj.u{3} = obj.u{3}.sym;
    
  case 16 % D2
    
    obj.u{1}.M = fillT2(d(:,1:5)); obj.u{1} = obj.u{1}.sym;
    
    obj.u{2}.M = fillT2(d(:,6:10)); obj.u{2} = obj.u{2}.sym;
    
    obj.u{3}.M = fillT2(d(:,11:15)); obj.u{3} = obj.u{3}.sym;
       
  case 18 % C3
    
    obj.u{1}.M = fillT3(d(:,1:7)); obj.u{1} = obj.u{1}.sym;
    obj.u{2} = vector3d(d(:,8:10).').';
    
  case {21,24} % D3
    
    obj.u{1}.M = fillT3(d(:,1:7)); obj.u{1} = obj.u{1}.sym;
    
    obj.u{2}.M = fillT2(d(:,8:12)); obj.u{2} = obj.u{2}.sym;
    
  case 27 % C4
    
    obj.u{1}.M = fillT4(d(:,1:14)); obj.u{1} = obj.u{1}.sym;
    obj.u{2} = vector3d(d(:,15:17).').';
    
  case 32 % D4
    
    obj.u{1}.M = fillT4(d(:,1:14)); obj.u{1} = obj.u{1}.sym;
    
    d = -sqrt(2)*[   ...
      d(:,1) + d(:,4) + d(:,6),...   % 11
      d(:,2) + d(:,7) + d(:,9),...   % 12
      d(:,3) + d(:,8) + d(:,10), ... % 13
      d(:,4) + d(:,11) + d(:,13) ... % 22 
      d(:,5) + d(:,12) + d(:,14)];   % 23
    
    obj.u{2}.M = fillT2(d); obj.u{2} = obj.u{2}.sym;
    
  case 35 % C6
    
    obj.u{1}.M = fillT6(d(:,1:27)); obj.u{1} = obj.u{1}.sym;
    obj.u{2} = vector3d(d(:,28:30).').';
    
  case 40 % D6
    
    obj.u{1}.M = fillT6(d(:,1:27)); obj.u{1} = obj.u{1}.sym;
    
    M1 = obj.u{1}.M;
    obj.u{2}.M = - sqrt(3)/4 * reshape(...
      M1(:,:,1,1,1,1,:) + M1(:,:,2,2,2,2,:) + M1(:,:,3,3,3,3,:) + ....
      + 2 * (M1(:,:,1,1,2,2,:) + M1(:,:,1,1,3,3,:) + M1(:,:,2,2,3,3,:)), 3,3,[]);
    
  case 42 % T
    
      obj.u{1}.M = fillT3(d(:,1:7)); obj.u{1} = obj.u{1}.sym;
    
  case 45 % O
            
    M = nan(3^4,size(d,1));
    M(ind43,:) = d.';
    
    M = reshape(M,3,3,3,3,[]);

    M(1 ,1, 2, 3,:) = -d(:,7)-d(:,9);
    M(1, 2, 2, 3,:) = -d(:,2)-d(:,6);
    M(1, 2, 3, 3,:) = -d(:,1)-d(:,5);
    h = -d(:,3)-d(:,4);
    M(1, 1, 1, 1,:) = h;
    M(3, 3, 3, 3,:) = -d(:,8)+d(:,3) + h;
    M(2, 2, 2, 2,:) = -d(:,8)+d(:,4) + h;
    
    obj.u{1}.M = M;
    obj.u{1} = obj.u{1}.sym;
    
end

% ensure the right shape if possible
if prod(s) == prod(size(obj)), obj = reshape(obj,s); end %#ok<PSIZE>

end

function M = fillT2(d)

M = nan(3^2,size(d,1));
M([1 2 3 5 6],:) = d.';
M = reshape(M,3,3,[]);
M(3,3,:) = -M(1,1,:) - M(2,2,:);

end

function M = fillT3(d)

M = nan(3^3,size(d,1));
M([10,19,13,22,25,23,26],:) = d.';
M = reshape(M,3,3,3,[]);

M(1,1,1,:) = -M(1,2,2,:) - M(1,3,3,:);
M(2,2,2,:) = -M(1,1,2,:) - M(2,3,3,:);
M(3,3,3,:) = -M(1,1,3,:) - M(2,2,3,:);

end
   
function M = fillT4(d)

M = nan(3^4,size(d,1));
M([1 28 55 37 64 73 40 67 76 79 41 68 77 80],:) = d.';
M = reshape(M,3,3,3,3,[]);

M(3,3,3,3,:) = -M(1,1,1,1,:) - 2*M(1,1,2,2,:) - 2*M(1,1,3,3,:) - ...
  M(2,2,2,2,:) - 2*M(2,2,3,3,:);

end

function M = fillT6(d)

M = nan(3^6,size(d,1));
M([1 244 487 325  568 649 352 595 676 703 361 604 685 712 721 364 607 688 715 724 727 365 608 689 716 725 728],:)= d.';
M = reshape(M,3,3,3,3,3,3,[]);

M(3,3,3,3,3,3,:,:) = -M(1,1,1,1,1,1,:,:)-M(2,2,2,2,2,2,:,:)-3*M(1,1,2,2,2,2,:,:)-3*M(1,1,3,3,3,3,:,:)-3*M(1,1,1,1,2,2,:,:)-3*M(2,2,3,3,3,3,:,:)-3*M(1,1,1,1,3,3,:,:)-3*M(2,2,2,2,3,3,:,:)-6*M(1,1,2,2,3,3,:,:);

end
    
