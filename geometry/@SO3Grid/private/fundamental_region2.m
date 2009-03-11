function ind = fundamental_region2(q,center,cs,ss)
%
%% Input
%
%% Output

% symmetrice
c_sym = ss *  center * cs;
omega = rotangle(c_sym * inverse(center));
[omega,c_sym] = selectMinbyRow(omega,c_sym);


% convert to rodriguez space
rq = quat2rodriguez(q); clear q;
rc_sym = quat2rodriguez(c_sym); 

% find rotation not part of the fundamental region
ind = true(numel(rq),1);
for i = 2:numel(rc_sym)
  
  d = rc_sym(i)-rc_sym(1);
  if norm(d)<=1e-10 % find something that is orthogonal to rc_sym    
    if abs(getx(rc_sym(1)))<=1e-5
      if isnull(gety(rc_sym(1))) && i > 2
        d = yvector;
      else
        d = xvector;
      end            
    else
      d = yvector;
    end
    nd = 0;
  else
    nd = norm(d).^2 /2;
  end
  
  ind = ind & dot(rq-rc_sym(1),d) <= nd;
  
end

