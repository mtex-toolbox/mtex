function obj = setDouble(obj,d)
% convert embedding to packed double
% inverse of double
%
% Syntax
%
%   obj = setDouble(obj,d);
%   
%
% Input
%  obj - @embedding
%  d - double
%
%
% Output
%  E - embedding
%
% See also
% OrientationEmbeddings
%
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
    
    d(:,[5,6,8]) = d(:,[5,6,8])./sqrt(2);
    d(:,[10,11,13]) = d(:,[10,11,13])./sqrt(2);
    tmp = 1/2*(sqrt(2/3)*d(:,4)+sqrt(2)*d(:,7));
    tmp2 = 1/2*(sqrt(2/3)*d(:,4)-sqrt(2)*d(:,7));
    d(:,4) = tmp;
    d(:,7) = tmp2;
    tmp = 1/2*(sqrt(2/3)*d(:,9)+sqrt(2)*d(:,12));
    tmp2 = 1/2*(sqrt(2/3)*d(:,9)-sqrt(2)*d(:,12));
    d(:,9) = tmp;
    d(:,12) = tmp2;
    
    
    
    obj.u{1} = vector3d(d(:,1:3).').';

    obj.u{2}.M = fillT2(d(:,4:8));  obj.u{2} = obj.u{2}.sym;
    
    obj.u{3}.M = fillT2(d(:,9:13)); obj.u{3} = obj.u{3}.sym;
    
    
    
  case 16 % D2
      
    d(:,[2,3,5]) = d(:,[2,3,5])./sqrt(2);
    d(:,[7,8,10]) = d(:,[7,8,10])./sqrt(2);
    d(:,[12,13,15]) = d(:,[12,13,15])./sqrt(2);
%     d(:,[5,6,8]) = d(:,[5,6,8])./sqrt(2);
%     d(:,[10,11,13]) = d(:,[10,11,13])./sqrt(2);
    d = isometricdot(d,1,4);
    d = isometricdot(d,6,9);
    d = isometricdot(d,11,14);
%     tmp = 1/2*(sqrt(2/3)*d(:,1)+sqrt(2)*d(:,4));
%     tmp2 = 1/2*(sqrt(2/3)*d(:,1)-sqrt(2)*d(:,4));
%     d(:,1) = tmp;
%     d(:,4) = tmp2;
%     tmp = 1/2*(sqrt(2/3)*d(:,6)+sqrt(2)*d(:,9));
%     tmp2 = 1/2*(sqrt(2/3)*d(:,6)-sqrt(2)*d(:,9));
%     d(:,6) = tmp;
%     d(:,9) = tmp2;
%     tmp = 1/2*(sqrt(2/3)*d(:,11)+sqrt(2)*d(:,14));
%     tmp2 = 1/2*(sqrt(2/3)*d(:,11)-sqrt(2)*d(:,14));
%     d(:,11) = tmp;
%     d(:,14) = tmp2;
    
    
    obj.u{1}.M = fillT2(d(:,1:5)); obj.u{1} = obj.u{1}.sym;
    
    obj.u{2}.M = fillT2(d(:,6:10)); obj.u{2} = obj.u{2}.sym;
    
    obj.u{3}.M = fillT2(d(:,11:15)); obj.u{3} = obj.u{3}.sym;
       
  case 18 % C3
    
    %d(:,[1,2,3,5,6,7]) = d(:,[1,2,3,5,6,7])./sqrt(3);
    d(:,4) = d(:,4)./sqrt(6);
    d = isometricdot3d(d,3,5);
    d = isometricdot3d(d,1,7);
    d = isometricdot3d(d,2,6);
    
    obj.u{1}.M = fillT3(d(:,1:7)); obj.u{1} = obj.u{1}.sym;
    obj.u{2} = vector3d(d(:,8:10).').';
    
  case {21,24} % D3
    
   %d(:,[1,2,3,5,6,7]) = d(:,[1,2,3,5,6,7])./sqrt(3);
   d(:,4) = d(:,4)./sqrt(6);
   d = isometricdot3d(d,3,5);
   d = isometricdot3d(d,1,7);
   d = isometricdot3d(d,2,6);
   d(:,[9,10,12]) = d(:,[9,10,12])./sqrt(2);
   d = isometricdot(d,8,11);
   
    obj.u{1}.M = fillT3(d(:,1:7)); obj.u{1} = obj.u{1}.sym;
    obj.u{2}.M = fillT2(d(:,8:12)); obj.u{2} = obj.u{2}.sym;
    
  case 27 % C4

    d(:,[2,3,7,10,12,14]) = d(:,[2,3,7,10,12,14])./sqrt(4);
    d(:,[5,8,9]) = d(:,[5,8,9])./sqrt(12);
    d = traceUnfix(d,[1,4,6,11,13],[1,6,6,1,6],[1,2,2,1,2]);

    obj.u{1}.M = fillT4(d(:,1:14)); obj.u{1} = obj.u{1}.sym;
    obj.u{2} = vector3d(d(:,15:17).').';

  case 32 % D4

    mult = [1,4,4,6,12,6,4,12,12,4,1,4,6,4];
    a = zeros(1,14); a([1,4,6]) = -sqrt(2);
    b = zeros(1,14); b([4,11,13]) = -sqrt(2);
    r = zeros(1,14); r([2,7,9]) = -sqrt(2);
    s = zeros(1,14); s([3,8,10]) = -sqrt(2);
    t = zeros(1,14); t([5,12,14]) = -sqrt(2);
    c = zeros(1,14); c([1,4,6,11,13]) = [1,2,2,1,2];
    C = [c; sqrt(3/2)*(a+b); sqrt(1/2)*(a-b); sqrt(2)*r; sqrt(2)*s; sqrt(2)*t];
    d = traceUnfix(d,1:14,mult,C);

    obj.u{1}.M = fillT4(d(:,1:14)); obj.u{1} = obj.u{1}.sym;
    
    d = -sqrt(2)*[   ...
      d(:,1) + d(:,4) + d(:,6),...   % 11
      d(:,2) + d(:,7) + d(:,9),...   % 12
      d(:,3) + d(:,8) + d(:,10), ... % 13
      d(:,4) + d(:,11) + d(:,13) ... % 22 
      d(:,5) + d(:,12) + d(:,14)];   % 23
    
    obj.u{2}.M = fillT2(d); obj.u{2} = obj.u{2}.sym;
    
  case 35 % C6

    d(:,[2,3,16,21,23,27]) = d(:,[2,3,16,21,23,27])./sqrt(6);
    d(:,[5,17,20]) = d(:,[5,17,20])./sqrt(30);
    d(:,[7,10,25]) = d(:,[7,10,25])./sqrt(20);
    d(:,[8,9,12,14,18,19]) = d(:,[8,9,12,14,18,19])./sqrt(60) ;
    d = traceUnfix(d,[1,22,4,6,11,15,24,26,13],[1,1,15,15,15,15,15,15,90],[1,1,3,3,3,3,3,3,6]);
    obj.u{1}.M = fillT6(d(:,1:27)); obj.u{1} = obj.u{1}.sym;
    obj.u{2} = vector3d(d(:,28:30).').';

  case 40 % D6

    mult = [1,6,6,15,30,15,20,60,60,20,15,60,90,60,15,6,30,60,60,30,6,1,6,15,20,15,6];
    p = zeros(1,27); p([1,11,15]) = -sqrt(3)/4; p([4,6,13]) = -sqrt(3)/2;
    q = zeros(1,27); q([4,22,26]) = -sqrt(3)/4; q([11,13,24]) = -sqrt(3)/2;
    r = zeros(1,27); r([2,16,20]) = -sqrt(3)/4; r([7,9,18]) = -sqrt(3)/2;
    s = zeros(1,27); s([3,17,21]) = -sqrt(3)/4; s([8,10,19]) = -sqrt(3)/2;
    t = zeros(1,27); t([5,23,27]) = -sqrt(3)/4; t([12,14,25]) = -sqrt(3)/2;
    c = zeros(1,27); c([1,22,4,6,11,15,24,26,13]) = [1,1,3,3,3,3,3,3,6];
    C = [c; sqrt(3/2)*(p+q); sqrt(1/2)*(p-q); sqrt(2)*r; sqrt(2)*s; sqrt(2)*t];
    d = traceUnfix(d,1:27,mult,C);

    obj.u{1}.M = fillT6(d(:,1:27)); obj.u{1} = obj.u{1}.sym;
    
    M1 = obj.u{1}.M;
    obj.u{2}.M = - sqrt(3)/4 * reshape(...
      M1(:,:,1,1,1,1,:) + M1(:,:,2,2,2,2,:) + M1(:,:,3,3,3,3,:) + ....
      + 2 * (M1(:,:,1,1,2,2,:) + M1(:,:,1,1,3,3,:) + M1(:,:,2,2,3,3,:)), 3,3,[]);
    
  case 42 % T
       
      %d = d./sqrt(3);
      d(:,4) = d(:,4)./sqrt(6);
      d = isometricdot3d(d,3,5);
      d = isometricdot3d(d,1,7);
      d = isometricdot3d(d,2,6);
      
      obj.u{1}.M = fillT3(d(:,1:7)); obj.u{1} = obj.u{1}.sym;
    
  case 45 % O

    C = zeros(6,9);
    C(1,[7,9]) = 1; C(2,[2,6]) = 1; C(3,[1,5]) = 1;
    C(4,[3,4]) = 1; C(5,[4,8]) = 1; C(6,[3,8]) = 1;
    C = sqrt([12;12;12;1;1;1]) .* C;
    d = traceUnfix(d,1:9,[4,4,6,6,4,4,4,6,4],C);

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
function d_neu = isometricdot(d,index1,index2)
    d_neu = d;
    d_neu(:,index1) = 1/2*(sqrt(2/3)*d(:,index1)+sqrt(2)*d(:,index2));
    d_neu(:,index2) = 1/2*(sqrt(2/3)*d(:,index1)-sqrt(2)*d(:,index2));
end
function d_neu = isometricdot3d(d,index1,index2)
    d_neu = d;
    d_neu(:,index1) = 1/2*(sqrt(2/5)*d(:,index1)+sqrt(2/3)*d(:,index2));
    d_neu(:,index2) = 1/2*(sqrt(2/5)*d(:,index1)-sqrt(2/3)*d(:,index2));
end
function d = traceUnfix(d,idx,mult,C)
% inverse of double.m's traceFix
G = diag(mult) + C.' * C;
R = chol(G);
d(:,idx) = d(:,idx) / R.';
end