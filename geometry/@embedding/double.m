function d = double(E,varargin)
% convert embedding to packed double
% 
% Syntax
%
%   d = double(E)
%   d = double(E,'full')
%
% Input
%  E - @embedding
%
% Options
%  full - return full embedding
%
% Output
%  d - double
%
% See also
% OrientationEmbeddings
%

if check_option(varargin,'full')
  
  d = cell(1,length(E.u));
  for k = 1:length(E.u)
    if E.u{k}.rank ==1
      d{k} = double(E.u{k});
    else
      d{k} = reshape(double(E.u{k}),[],size(E,1));
    end
    
  end
  
  d = vertcat(d{:}).';
  return;
  
end

ind2 = [1 2 3 5 6];

% d = {1 1 2; 1 1 3; 1 2 2; 1 2 3; 1 3 3; 2 2 3; 2 3 3};
% ind3 = sub2ind([3 3 3],[d{:,1}],[d{:,2}],[d{:,3}])
ind3 = [10,19,13,22,25,23,26];

% d = {1 1 1 1; 1 1 1 2; 1 1 1 3; 1 1 2 2; 1 1 2 3; 1 1 3 3; 1 2 2 2; 1 2 2 3; ...
%      1 2 3 3; 1 3 3 3; 2 2 2 2; 2 2 2 3; 2 2 3 3; 2 3 3 3};
% ind4 = sub2ind([3 3 3 3],[d{:,1}],[d{:,2}],[d{:,3}],[d{:,4}]);
ind4 = [1 28 55 37 64 73 40 67 76 79 41 68 77 80];
  
ind43 = ind4([2 3 4 6 7 10 12 13 14]);

% d = unique(combnk([1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3],6),'rows');
% ind6 = sub2ind([3 3 3 3 3 3],[d(:,1)],[d(:,2)],[d(:,3)],[d(:,4)],[d(:,5)],[d(:,6)]);
ind6 = [1 244 487 325  568 649 352 595 676 703 361 604 685 712 721 364 607 688 715 724 727 365 608 689 716 725 728 729];

% d = [1 1 2; 1 1 3; 1 2 2; 1 2 3; 1 3 3; 2 2 3; 2 3 3 ];
% indT = sub2ind([3 3 3],[d(:,1)],[d(:,2)],[d(:,3)]);
indT = [10 19 13 22 25 23 26];
    
switch E.CS.Laue.id
    
  case 2 % C1
    
    d = [E.u{1}.xyz,E.u{2}.xyz,E.u{3}.xyz];
    
  case {5,8,11} % C2

    M2 = reshape(E.u{2}.M,9,[]).';
    M3 = reshape(E.u{3}.M,9,[]).';
    
    d = [E.u{1}.xyz, M2(:,ind2),M3(:,ind2)];
    d(:,[5,6,8]) = sqrt(2) * d(:,[5,6,8]);
    d(:,[10,11,13]) = sqrt(2) *  d(:,[10,11,13]);
    d = isometricdot(d,4,7);
    d = isometricdot(d,9,12);
%     tmp = sqrt(3/2)*(d(:,4)+d(:,7));
%     tmp2 = sqrt(1/2)*(d(:,4)-d(:,7));
%     d(:,4) = tmp;
%     d(:,7) = tmp2;
%     tmp = sqrt(3/2)*(d(:,9)+d(:,12));
%     tmp2 = sqrt(1/2)*(d(:,9)-d(:,12));
%     d(:,9) = tmp;
%     d(:,12) = tmp2;
    
  case 16 % D2
    
    M1 = reshape(E.u{1}.M,9,[]).';
    M2 = reshape(E.u{2}.M,9,[]).';
    M3 = reshape(E.u{3}.M,9,[]).';
    
    d = [M1(:,ind2),M2(:,ind2),M3(:,ind2)];
    d(:,[2,3,5]) = sqrt(2) * d(:,[2,3,5]);
    d(:,[7,8,10]) = sqrt(2) *  d(:,[7,8,10]);
    d(:,[12,13,15]) = sqrt(2) *  d(:,[12,13,15]);
    d = isometricdot(d,1,4);
    d = isometricdot(d,6,9);
    d = isometricdot(d,11,14);
%     tmp = sqrt(3/2)*(d(:,1)+d(:,4));
%     tmp2 = sqrt(1/2)*(d(:,1)-d(:,4));
%     d(:,1) = tmp;
%     d(:,4) = tmp2;
%     tmp = sqrt(3/2)*(d(:,6)+d(:,9));
%     tmp2 = sqrt(1/2)*(d(:,6)-d(:,9));
%     d(:,6) = tmp;
%     d(:,9) = tmp2;
%     tmp = sqrt(3/2)*(d(:,11)+d(:,14));
%     tmp2 = sqrt(1/2)*(d(:,11)-d(:,14));
%     d(:,11) = tmp;
%     d(:,14) = tmp2;
    
       
  case 18 % C3

    M = reshape(E.u{1}.M,27,[]).';
    d = [M(:,ind3),E.u{2}.xyz];
    %d(:,[1,2,3,5,6,7]) = d(:,[1,2,3,5,6,7]).*sqrt(3);
    d(:,4) = d(:,4).*sqrt(6);
    d = isometricdot3d(d,3,5);
    d = isometricdot3d(d,1,7);
    d = isometricdot3d(d,2,6);

  case {21,24} % D3
    
    M1 = reshape(E.u{1}.M,27,[]).';
    M2 = reshape(E.u{2}.M,9,[]).';
    
    d = [M1(:,ind3),M2(:,ind2)];
    %d(:,[1,2,3,5,6,7]) = sqrt(3) * d(:,[1,2,3,5,6,7]);
    d(:,4) = sqrt(6) * d(:,4);
    d = isometricdot3d(d,3,5);
    d = isometricdot3d(d,1,7);
    d = isometricdot3d(d,2,6);
    d(:,[9,10,12]) = sqrt(2) * d(:,[9,10,12]);
    d = isometricdot(d,8,11);
    
%     tmp = sqrt(3/2)*(d(:,8)+d(:,11));
%     tmp2 = sqrt(1/2)*(d(:,8)-d(:,11));
%     d(:,8) = tmp;
%     d(:,11) = tmp2;
    
    
  case 27 % C4
    
    M1 = reshape(E.u{1}.M,3^4,[]).';
    d = [M1(:,ind4),E.u{2}.xyz];
    d(:,[2,3,7,10,12,14]) =  sqrt(4) * d(:,[2,3,7,10,12,14]);
    d(:,[5,8,9]) = sqrt(12) * d(:,[5,8,9]);
    d = traceFix(d,[1,4,6,11,13],[1,6,6,1,6],[1,2,2,1,2]);

  case 32 % D4

    % D4 has no independent second tensor, so fold u{2} into the packing of u{1}
    M1 = reshape(E.u{1}.M,3^4,[]).';
    d = M1(:,ind4);
    mult = [1,4,4,6,12,6,4,12,12,4,1,4,6,4];
    a = zeros(1,14); a([1,4,6]) = -sqrt(2);
    b = zeros(1,14); b([4,11,13]) = -sqrt(2);
    r = zeros(1,14); r([2,7,9]) = -sqrt(2);
    s = zeros(1,14); s([3,8,10]) = -sqrt(2);
    t = zeros(1,14); t([5,12,14]) = -sqrt(2);
    c = zeros(1,14); c([1,4,6,11,13]) = [1,2,2,1,2];
    C = [c; sqrt(3/2)*(a+b); sqrt(1/2)*(a-b); sqrt(2)*r; sqrt(2)*s; sqrt(2)*t];
    d = traceFix(d,1:14,mult,C);

  case 35 % C6
    M1 = reshape(E.u{1}.M,3^6,[]).';
    d = [M1(:,ind6(1:end-1)),E.u{2}.xyz];
    d(:,[2,3,16,21,23,27]) = sqrt(6) * d(:,[2,3,16,21,23,27]);
    d(:,[5,17,20]) = sqrt(30) * d(:,[5,17,20]);
    d(:,[7,10,25]) = sqrt(20) * d(:,[7,10,25]);
    d(:,[8,9,12,14,18,19]) = sqrt(60) * d(:,[8,9,12,14,18,19]);
    d = traceFix(d,[1,22,4,6,11,15,24,26,13],[1,1,15,15,15,15,15,15,90],[1,1,3,3,3,3,3,3,6]);

  case 40 % D6

    % D6 likewise has u{2} as a linear function of u{1} (see setDouble.m);
    % fold its norm contribution into the packing of all 27 components
    M1 = reshape(E.u{1}.M,3^6,[]).';
    d = M1(:,ind6(1:end-1));
    mult = [1,6,6,15,30,15,20,60,60,20,15,60,90,60,15,6,30,60,60,30,6,1,6,15,20,15,6];
    p = zeros(1,27); p([1,11,15]) = -sqrt(3)/4; p([4,6,13]) = -sqrt(3)/2;
    q = zeros(1,27); q([4,22,26]) = -sqrt(3)/4; q([11,13,24]) = -sqrt(3)/2;
    r = zeros(1,27); r([2,16,20]) = -sqrt(3)/4; r([7,9,18]) = -sqrt(3)/2;
    s = zeros(1,27); s([3,17,21]) = -sqrt(3)/4; s([8,10,19]) = -sqrt(3)/2;
    t = zeros(1,27); t([5,23,27]) = -sqrt(3)/4; t([12,14,25]) = -sqrt(3)/2;
    c = zeros(1,27); c([1,22,4,6,11,15,24,26,13]) = [1,1,3,3,3,3,3,3,6];
    C = [c; sqrt(3/2)*(p+q); sqrt(1/2)*(p-q); sqrt(2)*r; sqrt(2)*s; sqrt(2)*t];
    d = traceFix(d,1:27,mult,C);
     
    
  case 42 % T
    M1 = reshape(E.u{1}.M,3^3,[]).';
    d = M1(:,indT);
    d(:,4) = sqrt(6)*  d(:,4);
    d = isometricdot3d(d,3,5);
    d = isometricdot3d(d,1,7);
    d = isometricdot3d(d,2,6);
    
  case 45 % O
    
    M = reshape(E.u{1}.M,3^4,[]).';
    d = M(:,ind43);
    C = zeros(6,9);
    C(1,[7,9]) = 1; C(2,[2,6]) = 1; C(3,[1,5]) = 1;
    C(4,[3,4]) = 1; C(5,[4,8]) = 1; C(6,[3,8]) = 1;
    C = sqrt([12;12;12;1;1;1]) .* C;
    d = traceFix(d,1:9,[4,4,6,6,4,4,4,6,4],C);

end
end
function d_neu = isometricdot(d,index1,index2)
    d_neu = d;
    d_neu(:,index1) = sqrt(3/2)*(d(:,index1)+d(:,index2));
    d_neu(:,index2) = sqrt(1/2)*(d(:,index1)-d(:,index2));
end
function d_neu = isometricdot3d(d,index1,index2)
    d_neu = d;
    d_neu(:,index1) = sqrt(5/2)*(d(:,index1)+d(:,index2));
    d_neu(:,index2) = sqrt(3/2)*(d(:,index1)-d(:,index2));
end
function d = traceFix(d,idx,mult,C)
% isometrically repack d(:,idx) to also account for the norm contribution
% of the tensor entries eliminated by the trace-free constraint(s) that
% express those entries as C * d(:,idx).' (rows of C are the constraints,
% each pre-scaled by the sqrt of the multiplicity of the entry it
% eliminates; mult are the multiplicities of the free entries in d(:,idx))
%
% d(:,idx) * mult(:).' * d(:,idx).' + norm(C*d(:,idx).')^2 is invariant
% under this repacking, i.e. R = chol(diag(mult) + C.'*C) gives an exact
% factorization of that quadratic form

G = diag(mult) + C.' * C;
R = chol(G);
d(:,idx) = d(:,idx) * R.';
end

function test %#ok<DEFNU>
% double() should be an isometry: Euclidean distance between packed
% vectors should equal the tensorial distance between the embeddings

cs = crystalSymmetry('6/mmm');
ori = orientation.rand(20,cs);

e = embedding(ori);
d = double(e);

id1 = randi(20,50,1);
id2 = randi(20,50,1);

distTensor = norm(e(id1) - e(id2));
distEuclid = sqrt(sum((d(id1,:) - d(id2,:)).^2,2));

disp(max(abs(distTensor - distEuclid)));

end
