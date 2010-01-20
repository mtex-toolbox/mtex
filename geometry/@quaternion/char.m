function s = char(q,varargin)
% quaternion to char

if length(q) == 1
  if check_option(varargin,'EULER')
    [alpha,beta,gamma] = quat2euler(q);
    s = ['(',int2str(alpha/degree),mtexdegchar,',',int2str(beta/degree),mtexdegchar,',',int2str(gamma/degree),mtexdegchar,')'];
  elseif q.a == 1
    s = 'identical rotation';
  else
    v = vector3d(q.b,q.c,q.d);
    s = ['rot axis: ',char(v./norm(v)),', rot angle: ',int2str(2*acos(q.a)/degree),mtexdegchar];
  end
else
  s = ['Quaternions: ',num2str(size(q,1)),'x',num2str(size(q,2))];
end
