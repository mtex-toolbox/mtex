function w = K(kk,g1,g2,CS,SS,varargin)
% evaluate kernel modulo symmetries
% usage: w = K(kk,g1,g2,CS,SS,<options>)
%
%% Input
%  kk     - @kernel
%  g1, g2 - @quaternion(s)
%  CS, SS - crystal , specimen @symmetry
%
%% Options
%  EXACT - 
%  ESSILON
%
% general formula:
% K(g1,g2) = Sum(g S) Sum(l) A_l Tr T_l(g1^-1 g g2)
% where Tr T_l(x) = [sin(x/2)+sin(x*l)]/sin(x/2)


if check_option(varargin,'EXACT')
  epsilon = pi;
else 
  epsilon = get_option(varargin,'ESSILON',gethw(kk)*3);
end

% wheter it makes sence to use a sophisticated algorithm 
% for distance matrix calculation
simple_matrix = check_option(varargin,'simple_matrix') || isa(g1,'quaternion') ||...
	isa(g2,'quaternion') || length(SS) > 1 || epsilon*length(CS)^(1/3)>pi;


if ~simple_matrix                   
  % calculate dist matrix
  spomega = distMatrix(g1,g2,epsilon);
  w = spfun(kk.K,spomega);
else
	g1 = quaternion(g1);
	g2 = quaternion(g2);
	w = sparse(numel(g1),numel(g2));
     
	for iks = 1:length(CS)
		for ips = 1:length(SS) % for all symmetries
			sg    = quaternion(SS,ips) * g1 * quaternion(CS,iks);  % rotate g1
      omega = dot_outer(sg,g2);      % calculate full distance matrix

%  z = find(omega>cos(epsilon));
%  if length(z) > numel(omega)/length(CS)/10, w = full(w); end
%  w(z) = w(z) +  kk.K(omega(z));
      
%  if length(z) > numel(omega)/length(CS)/10, w = full(w); end
      
      [y,x] = find(omega>cos(epsilon));
      dummy = sparse(y,x,kk.K(omega(sub2ind(size(w),y,x))),numel(g1),numel(g2));
      
      w = w + dummy;          
      
		end
	end
end
w = w / length(CS) / length(SS);
