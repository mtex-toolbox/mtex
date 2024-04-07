function dmn = Wigner_d_recursion(varargin)
% Compute Wigner-d matrices by recursion formula.
% Therefore it is possible to generate a Wigner-d matrix by input of the
% two Wigner-d matrices with next smaller harmonic degree. It is also
% possible to calculate all Wigner-d matrices up to given harmonc degree L.
%
% Syntax
%   dmn = Wigner_d_recursion(dlmin1,dlmin2,beta)
%   dmn = Wigner_d_recursion(dlmin1,dlmin2,beta,'half')
%   dmn = Wigner_d_recursion(L,beta)
%
% Input
%   L   - harmonic degree
%   beta - second Euler angle
%   dlmin1,dlmin2 - Wigner-d matrices of harmonic degree L-1 and L-2
%
% Output
%   dmn - Wigner d matrix d^L_(m,n) 
%         or cell-array of all Wigner-d matrices up to harmonic degree L
%
% Example
%   Wigner_d_recursion(Wigner_D(4,pi/2),Wigner_D(3,pi/2),pi/2)
%   Wigner_d_recursion(64,pi/2)
%

% Idea: We construct the current Wigner-d matrix by three term recurrsion.
% (refer Antje Vollrath - A Fast Fourier Algorithm on the Rotation Group, section 2.3) [*1*]
% Therefore we can not produce the first and last row and column. We get 
% this exterior frame very easily by representation of Wigner-d matrix with
% Jacobi Polynomials.
% (refer Varshalovich - Quantum Theory of Angular Momentum - 1988, section 4.3.4)      [*2*]
% Because of symmetry properties it is sufficient to calculate the left
% half, look:
%         d = ( A | A* )       | represents column with index 0
%                              * corresponds to flip(flip(.,2),1)
% Hence we only calculate A and the column with index 0. 
% We get the remaining part by symmetry properties.


if length(varargin)>=3
  
  % calculate harmonic degree of new Wigner-d matrix
  sz = size(varargin{1});
  L = (sz(1)+1)/2;
  
  % load input
  dlmin1 = varargin{1}(:,1:L);
  % transform the smaller one to same size as bigger one by adding zeros
  dlmin2 = zeros(2*L-1,L);
  dlmin2(2:end-1,2:end) = varargin{2}(:,1:L-1);
  % get second Euler angle
  beta = varargin{3};
  
  % do recursion step
  dmn = recurrence(dlmin1,dlmin2,L,beta);

  % use symmetry property of Wigner-d
  if ~check_option(varargin,'half')
    dmn = [dmn, flip(flip(dmn(:,1:end-1),1),2)];
  end

else

  % load input
  L = varargin{1};
  beta = varargin{2};
  
  % create cell array
  dmn = cell(L,1);
  
  % generate start values
  dlmin2 = zeros(3,2); dlmin2(2,2) = 1;
  dlmin1 = Wigner_D(1,beta); dmn{1} = dlmin1; dlmin1 = dlmin1(:,1:2);
  
  for l=2:L
    
    % do recursion step
    dnew = recurrence(dlmin1,dlmin2,l,beta);
    
    % update iteratives for next recursion step
    dlmin2 = zeros(2*l+1,l+1);
    dlmin2(2:end-1,2:end) = dlmin1;
    dlmin1 = dnew;
    
    % do recursion and use symmetry property
    d = [dnew, flip(flip(dnew(:,1:end-1),1),2)];
    
    % save result
    dmn{l} = d;

  end

end

end


    
function d_new = recurrence(d_lmin1,d_lmin2,l,beta)
% The recurence formula only yields the interior values, i.e. the frame
% (first and last row and column) is missing. Wigner-d is symmetric. Hence
% speed up by calculating only one of the symmetrically equivalent parts.

  % do three-term recusion and receive inner values
  nenner = sqrt((l^2-(-l+1:0).^2).*(l^2-(-l+1:l-1)'.^2));
  u = l*(2*l-1)./nenner;
  v = -(2*l-1)/(l-1) * ((-l+1:0).*(-l+1:l-1)') ./ nenner;
  w = -(l/(l-1)) * sqrt(((l-1)^2-(-l+1:0).^2).* ...
    ((l-1)^2-(-l+1:l-1)'.^2)) ./ nenner;
  d_interior = (u*cos(beta)+v) .* d_lmin1 + w .* d_lmin2;

  % construct outer part (first and last column and first row)
  % binomial coefficients for all values [(2j 0),(2j 1), ... ,(2j j)]
  % using factorial is faster but yields NaNs
  B_1 = ((l+1:2*l)>=(2*l+1:-1:l+1)').*(l:2*l-1) +1;
  B_2 = B_1-(2*l:-1:l)'; B_2(B_2<0.5)=1;
  if beta==pi/2
    A = sqrt(B_1'./B_2'/4);
    if l>500
      while size(A,1)>1
        len = size(A,1);
        A = sort(A,1);
        if ~iseven(len)
          A(1,:) = A(end,:).*A(1,:);
          A(end,:) = [];
          len = len-1;
        end
        A = A(1:len/2,:).*flip(A(len/2+1:end,:),1);
      end
      sq_binom = A;
    else
      sq_binom = prod(A,1);
    end
    d_exterior = [sq_binom, flip(sq_binom(1:end-1))];
  else
    sq_binom = sqrt(prod(B_1'./B_2',1));
    % absolut values of first and last line/column
    d_exterior = [sq_binom, flip(sq_binom(1:end-1))] ...
      .*(sin(beta/2).^(0:2*l)) .* (cos(beta/2).^(2*l:-1:0));
  end

  % compose new Wigner-d
  d_new = zeros(2*l+1,l+1);
  d_new(1,:) = d_exterior(1:l+1);
  d_new(:,1) = d_exterior.*(-1).^(0:2*l);
  d_new(end,:) = d_exterior(end:-1:l+1).*(-1).^(0:l);

  % correct sign of the outers
  [m,n] = meshgrid(-l:0,-l:l);
  d_new = d_new .* (-1).^(n.*(n<0)+m.*(m<0));

  % add inner values received by recursion
  d_new(2:end-1,2:end) = d_interior;

end