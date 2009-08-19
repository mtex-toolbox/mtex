function [m,er] = Miller(h,k,l,n,CS)
% constructor
%% Input
%  h,k,l,n(optional) - double
%  CS - crystal @symmetry

er = 0;
switch nargin 
	case 0
		m.h = 1;
		m.k = 0;
		m.l = 0;
    m.CS = symmetry;
	case 1
    argin_check(h,'Miller');
		m = h;
	case 3
    argin_check(h,'double');
    argin_check(k,'double');
    argin_check(l,'double');    
		m.h = h;
    m.k = k;
    m.l = l;
    m.CS = symmetry;
	case 4
    argin_check(h,'double');
    argin_check(k,'double');
    argin_check(l,'double');    
    m.h = h;
    m.k = k;
    if isa(n,'symmetry')
      m.l = l;
      m.CS = n;
    elseif isa(n,'double')
      m.l = n;
      m.CS = symmetry;
      if h+k+l ~= 0
        if nargout == 2
          er = 1;
        else
          warning(['Convention h+k+i=0 violated! I assume i = ',int2str(-h-k)]); %#ok<WNTAG>
        end
      end
    else
      error('No symmetry specified in Miller!');
    end
  case 5
    argin_check(h,'double');
    argin_check(k,'double');
    argin_check(l,'double');    
    argin_check(n,'double');    
    argin_check(CS,'symmetry');    
    m.h = h;
    m.k = k;
    m.l = n;
    if h+k+l ~= 0
      warning(['Convention h+k+i=0 violated! I assume i = ',int2str(-h-k)]); %#ok<WNTAG>
    end
    m.CS = CS;
end

if length(m.h)>1
	for i=1:length(h)
		mm(i) = Miller(m.h(i),m.k(i),m.l(i),m.CS); %#ok<AGROW>
	end
	m = mm;
else
	superiorto('symmetry','vector3d','quaternion');
	m = class(m,'Miller');	
end
