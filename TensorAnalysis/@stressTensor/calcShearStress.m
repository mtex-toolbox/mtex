function [tauMax,m,n,tau,ind] = calcShearStress(sigma,m,n,varargin)
% shear stress
%
% Syntax
%   [tauMax,m,n,tau] = calcShearStress(sigma,m,n)
%
% Formula
%
%  q = T_i1i2i3...id v_i1 v_i2 v_i3 ... v_id
%
% Input
%  sigma -  @stressTensor
%  m - normal vector the the slip or twinning plane
%  n - Burgers vector (slip) or twin shear direction (twinning)
%
% Output
%  tauMax - maximum shear stress
%  m      - active plane
%  n      - active direction
%  tau    - shear stresses with respect to all planes
%
% Options
%  symmetrise - consider also all symmetrically equivalent  planes and directions
%
% See also
%

if check_option(varargin,'symmetrise')
  
  [m,l] = symmetrise(m,'antipodal');
  [n,l] = symmetrise(n,'antipodal');
  
  %m = symmetrise(m);
  %n = symmetrise(n);
  
  [r,c] = find(isnull(dot_outer(m,n,'noSymmetry')));

  m = m(r);
  n = n(c);
  
else
  assert(length(m)==length(n),'Number of planes and directions must be the same.');
end

tau = zeros(length(m),length(sigma));

for i = 1:length(m)

  R = SchmidTensor(m(i),n(i),varargin{:});

  tau(i,:) = EinsteinSum(R,[-1 -2],sigma,[-1 -2]);
  
end

if length(m)>1
  %[tauMax,ind] = max(abs(tau));
  [~,ind] = max(abs(tau));
  tauMax = tau(sub2ind(size(tau),ind,1:size(tau,2)));
  m = m(ind);
  n = n(ind);
else
  tauMax = tau;
  ind = ones(size(tauMax));
end
