function odf = fibreODF(h,r,varargin)
% defines an fibre symmetric ODF
%
%% Description
% *fibreODF* defines a fibre symmetric ODF with respect to 
% a crystal direction |h| and a specimen directions |r|. The
% shape of the ODF is defined by a @kernel function.
%
%% Syntax
%   h = Miller(h,k,l,CS)
%   r = vector3d(x,y,z);
%   odf = fibreODF(h,r) % default halfwith 10*degree
%   odf = fibreODF(h,r,'halfwidth',15*degree) % specify halfwidth
%   odf = fibreODF(h,r,kernel) % specify @kernel shape
%   odf = fibreODF(h,r,CS,SS)  % specify crystal and specimen symmetry
%
%% Input
%  h      - @Miller / @vector3d crystal direction
%  r      - @vector3d specimen direction
%  CS, SS - crystal, specimen @symmetry
%  hw     - halfwidth of the kernel (default -- 10°)
%  kernel - @kernel function (default -- de la Vallee Poussin)
%
%% Output
%  odf - @ODF
%
%% See also
% ODF/ODF uniformODF unimodalODF

argin_check(h,'Miller');
argin_check(r,'vector3d');
if nargin > 2 && isa(varargin{1},'symmetry')
  CS = varargin{1};
  h = ensureCS(CS,{h});
else
  CS = get(h,'CS');
end
if nargin > 3 && isa(varargin{2},'symmetry')
  SS = varargin{2};
else
  SS = symmetry('triclinic');
end

if check_option(varargin,'bingham') % Bingham distributed ODF
  
  kappa = get_option(varargin,'bingham',10);
  
  if length(kappa) == 1,
    kappa = [kappa, kappa 0 0];
  elseif numel(kappa) < 4 
    kappa = [kappa(1:2) 0 0];
  end
  
  h = normalize(h);
  r = normalize(r);
  
  qr = quaternion(0,r);
  qh = quaternion(0,h);
  
  q1 = idquaternion - qr*qh;
  q2 = qr+qh;
  
  if isnull(norm(h-r))
    v1 = orth(h);
    v2 = cross(h,v1);
    q3 = quaternion(0,v1);
    q4 = quaternion(0,v2);
  else
    q3 = idquaternion + qr*qh;
    q4 = qr-qh;
  end
  
  A = normalize([q1,q2,q3,q4]);

  if 4-sum(diag(dot_outer(A,A))) > 10^-10,  
    warning('could not construct orthogonal rotations A, resulting Bingham Distribution may be inexact');
  end
  
  odf = BinghamODF(kappa,A,CS,SS);
  % reverse:
  %h_0 = q_1^* q_2
  %r_0 = q_2 q_1^*.
    
else % pure FibreODF

  if ~isempty(varargin) && isa(varargin{1},'kernel')
    psi = varargin{1};
  else
    hw = get_option(varargin,'halfwidth',10*degree);
    psi = kernel('de la Vallee Poussin','halfwidth',hw);
  end

  odf = ODF({h,r},1,psi,CS,SS,'fibre');
end
