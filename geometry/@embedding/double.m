function d = double(E)

ind2 = [1 2 3 5 6];

%d = {1 1 2; 1 1 3; 1 2 2; 1 2 3; 1 3 3; 2 2 3; 2 3 3};
%ind3 = sub2ind([3 3 3],[d{:,1}],[d{:,2}],[d{:,3}])
ind3 = [10,19,13,22,25,23,26];

%d = {1 1 1 1; 1 1 1 2; 1 1 1 3; 1 1 2 2; 1 1 2 3; 1 1 3 3; 1 2 2 2; 1 2 2 3; ...
%      1 2 3 3; 1 3 3 3; 2 2 2 2; 2 2 2 3; 2 2 3 3; 2 3 3 3};
%ind4 = sub2ind([3 3 3 3],[d{:,1}],[d{:,2}],[d{:,3}],[d{:,4}]);
ind4 = [1 28 55 37 64 73 40 67 76 79 41 68 77 80];    
  
ind43 = ind4([2 3 4 6 7 10 12 13 14]);

% d = unique(combnk([1 1 1 1 1 1 2 2 2 2 2 2 3 3 3 3 3 3],6),'rows');
%ind6 = sub2ind([3 3 3 3 3
%3],[d(:,1)],[d(:,2)],[d(:,3)],[d(:,4)],[d(:,5)],[d(:,6)]);
  ind6 = [1 244 487 325  568 649 352 595 676 703 361 604 685 712 721 364 607 688 715 724 727 365 608 689 716 725 728 729];

  %d = [1 1 2; 1 1 3; 1 2 2; 1 2 3; 1 3 3; 2 2 3; 2 3 3 ];
%indT = sub2ind([3 3 3],[d(:,1)],[d(:,2)],[d(:,3)]);
  indT = [10 19 13 22 25 23 26];          


%%
    
switch E.CS.Laue.id
    
  case 2 % C1
    
    d = cat(3,double(E.u{1}),double(E.u{2}),double(E.u{3}));
    d = reshape(d,[],9);
    
  case {5,8,11} % C2

    M2 = reshape(E.u{2}.M,9,[]).';
    M3 = reshape(E.u{3}.M,9,[]).';
    
    d = [reshape(double(E.u{1}),[],3), M2(:,ind2),M3(:,ind2)];
    
  case 16 % D2
    
    M1 = reshape(E.u{1}.M,9,[]).';
    M2 = reshape(E.u{2}.M,9,[]).';
    M3 = reshape(E.u{3}.M,9,[]).';
    
    d = [M1(:,ind2),M2(:,ind2),M3(:,ind2)];
       
  case 18 % C3

    M = reshape(E.u{1}.M,27,[]).';
    d = [M(:,ind3),reshape(double(E.u{2}),[],3)];

  case {21,24} % D3
    
    M1 = reshape(E.u{1}.M,27,[]).';
    M2 = reshape(E.u{2}.M,9,[]).';
    
    d = [M1(:,ind3),M2(:,ind2)];
    
  case 27 % C4
    
    M1 = reshape(E.u{1}.M,3^4,[]).';   
    d = [M1(:,ind4),reshape(double(E.u{2}),[],3)];
    
  case 32 % D4

    M1 = reshape(E.u{1}.M,3^4,[]).';
    d = M1(:,ind4);
    
  case 35 % C6
    M1 = reshape(E.u{1}.M,3^6,[]).';
    d = [M1(:,ind6(1:end-1)),reshape(double(E.u{2}),[],3)];
    
  case 40 % D6
     M1 = reshape(E.u{1}.M,3^6,[]).';
     d = M1(:,ind6(1:end-1));
    
  case 42 % T
    M1 = reshape(E.u{1}.M,3^3,[]).';
    d = M1(:,indT);
    
  case 45 % O
    
    M = reshape(E.u{1}.M,3^4,[]).';
    d = M(:,ind43);
            
end
end