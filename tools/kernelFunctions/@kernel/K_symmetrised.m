function w = K_symmetrised(psi,q1,q2,CS,SS,varargin)
% evaluate kernel modulo symmetries
%
% Input
%  psi    - @kernel
%  q1, q2 - @quaternion(s)
%  CS, SS - crystal , specimen @symmetry
%
% Options
%  exact - 
%  epsilon - 
%
% general formula:
% K(q1,q2) = Sum(S) Sum(l) A_l Tr T_l(s1^-1 q1 s2)

% only the pur rotational part is of interest 
% TODO
qCS = unique(quaternion(CS));
qSS = unique(quaternion(SS));

if check_option(varargin,'exact')
  epsilon = pi;
else 
  epsilon = min(pi,get_option(varargin,'epsilon',psi.halfwidth*3));
end

% how to use sparse matrix representation 
if isa(q1,'SO3Grid')
  lg1 = length(q1);
else
  lg1 = -length(q1);
end
if isa(q2,'SO3Grid')
  lg2 = length(q2);
else
  lg2 = -length(q2);
end


if epsilon>2*pi/CS.Laue.multiplicityZ % full matrixes
 
  q1 = quaternion(q1);
  q2 = quaternion(q2);
  w = zeros(length(q1),length(q2));
     
	for iks = 1:length(qCS)
		for ips = 1:length(qSS) % for all symmetries
      
			sg    = qSS(ips) * q1 * qCS(iks);  % rotate g1
      omega = abs(dot_outer(sg,q2));      % calculate full distance matrix            
      w = w + psi.K(omega);          
      
		end
  end  
  
elseif (lg1>0 || lg2>0) && ~check_option(varargin,'old')

  w = sparse(abs(lg1),abs(lg2));
  
  % sum over specimen symmetry
  ssq = quaternion(SS);

  if (lg1 >= lg2)              % first argument is SO3Grid
    for issq = 1:length(ssq)
      d = abs(dot_outer(q1,ssq(issq)*quaternion(q2),'epsilon',epsilon,...
        'nospecimensymmetry'));
        w = w + spfun(@psi.K,d);
    end    
  else                         % second argument is SO3Grid
    for issq = 1:length(ssq)
      d = abs(dot_outer(q2,ssq(issq)*quaternion(q1),'epsilon',epsilon,...
        'nospecimensymmetry'));
      w = w + spfun(@psi.K,d.');
    end
  end

else
  
	q1 = quaternion(q1);
	q2 = quaternion(q2);
  
	w = sparse(length(q1),length(q2));
     
	for iks = 1:length(qCS)
		for ips = 1:length(qSS) % for all symmetries
      
      if abs(lg1) > abs(lg2)
        sg    = qSS(ips) * q2 * qCS(iks);  % rotate g1
        omega = abs(dot_outer(q1,sg));      % calculate full distance matrix
      else
        sg    = qSS(ips) * q1 * qCS(iks);  % rotate g1
        omega = abs(dot_outer(sg,q2));      % calculate full distance matrix
      end
      
%  z = find(omega>cos(epsilon));
%  if length(z) > length(omega)/length(CS)/10, w = full(w); end
%  w(z) = w(z) +  kk.K(omega(z));
      
%  if length(z) > numel(omega)/length(CS)/10, w = full(w); end
      
      [y,x] = find(omega>cos(epsilon));
      dummy = sparse(y,x,psi.K(omega(sub2ind(size(w),y,x))),length(q1),length(q2));
      
      w = w + dummy;          
      
		end
  end  

end
%nnz(w)
w = w / length(qCS) / length(qSS);
