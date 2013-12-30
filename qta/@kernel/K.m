function w = K(kk,g1,g2,CS,SS,varargin)
% evaluate kernel modulo symmetries
%
% Input
%  kk     - @kernel
%  g1, g2 - @quaternion(s)
%  CS, SS - crystal , specimen @symmetry
%
% Options
%  exact - 
%  epsilon - 
%
% general formula:
% K(g1,g2) = Sum(g S) Sum(l) A_l Tr T_l(g1^-1 g g2)
% where Tr T_l(x) = [sin(x/2)+sin(x*l)]/sin(x/2)

% only the pur rotational part is of interest
qCS = unique(quaternion(CS));
qSS = unique(quaternion(SS));

if check_option(varargin,'EXACT')
  epsilon = pi;
else 
  epsilon = min(pi,get_option(varargin,'EPSILON',gethw(kk)*3));
end

% how to use sparse matrix representation 
if isa(g1,'SO3Grid')
  lg1 = length(g1);
else
  lg1 = -length(g1);
end
if isa(g2,'SO3Grid')
  lg2 = length(g2);
else
  lg2 = -length(g2);
end


if epsilon>rotangle_max_z(CS,'antipodal') % full matrixes
 
  g1 = quaternion(g1);
  g2 = quaternion(g2);
  w = zeros(length(g1),length(g2));
     
	for iks = 1:length(qCS)
		for ips = 1:length(qSS) % for all symmetries
      
			sg    = qSS(ips) * g1 * qCS(iks);  % rotate g1
      omega = abs(dot_outer(sg,g2));      % calculate full distance matrix            
      w = w + kk.K(omega);          
      
		end
  end  
  
elseif (lg1>0 || lg2>0) && ~check_option(varargin,'old')

  w = sparse(abs(lg1),abs(lg2));
  
  % sum over specimen symmetry
  ssq = quaternion(SS);

  if (lg1 >= lg2)              % first argument is SO3Grid
    for issq = 1:length(ssq)
      d = abs(dot_outer(g1,ssq(issq)*quaternion(g2),'epsilon',epsilon,...
        'nospecimensymmetry'));
        w = w + spfun(kk.K,d);
    end    
  else                         % second argument is SO3Grid
    for issq = 1:length(ssq)
      d = abs(dot_outer(g2,ssq(issq)*quaternion(g1),'epsilon',epsilon,...
        'nospecimensymmetry'));
      w = w + spfun(kk.K,d.');
    end
  end

else
  
	g1 = quaternion(g1);
	g2 = quaternion(g2);
  
	w = sparse(length(g1),length(g2));
     
	for iks = 1:length(qCS)
		for ips = 1:length(qSS) % for all symmetries
      
      if abs(lg1) > abs(lg2)
        sg    = qSS(ips) * g2 * qCS(iks);  % rotate g1
        omega = abs(dot_outer(g1,sg));      % calculate full distance matrix
      else
        sg    = qSS(ips) * g1 * qCS(iks);  % rotate g1
        omega = abs(dot_outer(sg,g2));      % calculate full distance matrix
      end
      

%  z = find(omega>cos(epsilon));
%  if length(z) > length(omega)/length(CS)/10, w = full(w); end
%  w(z) = w(z) +  kk.K(omega(z));
      
%  if length(z) > numel(omega)/length(CS)/10, w = full(w); end
      
      [y,x] = find(omega>cos(epsilon));
      dummy = sparse(y,x,kk.K(omega(sub2ind(size(w),y,x))),length(g1),length(g2));
      
      w = w + dummy;          
      
		end
  end  

end
%nnz(w)
w = w / length(qCS) / length(qSS);
