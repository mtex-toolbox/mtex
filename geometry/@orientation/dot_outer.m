function d = dot_outer(o1,o2,varargin)
% dot_outer
%
% Syntax
%   d = dot_outer(o1,o2)
%   d = dot_outer(o1,o2,'noSymmetry')
%
% Input
%  o1, o2 - @orientation
%
% Output
% d - double of size length(o1) < length(o2)
%

% TODO: does not work for orientations of different phase!!

if check_option(varargin,'noSymmetry')
  d = dot_outer@rotation(o1,o2);
  return
end

% get symmetries and ensure both arguments are at least rotations
if isa(o1,'orientation')
  if isa(o2,'orientation') && ~eq(o1.CS,o2.CS,'Laue')
    error('comparing orientations of different phase not yet supported');
  end
  cs = o1.CS; ss = o1.SS;
  o2 = rotation(o2);
else
  cs = o2.CS; ss = o2.SS;
  o1 = rotation(o1);
end

if check_option(varargin,'noSym2'), ss = []; end


% ensure there is something to do
l1 = length(o1); l2 = length(o2);
if l1 * l2 == 0, d = []; return; end

% maybe we can shrink down everything to quaternion
if isLaue(cs) || isLaue(ss) || (cs.isProper && isProper(ss) ...
    && all(o1.i(:) == o1.i(1)) && all(o2.i(:) == o1.i(1)))

  cs = cs.properGroup; 
  if ~isempty(ss), ss = ss.properGroup; end
  
  if check_option(varargin,'all')
    d = dot_outer_quat(o1,symmetrise(o2,cs,ss).');
    d = reshape(d,length(o1),length(o2),[]);
  elseif (l1 < l2) && (l1>0)
    d = dot_outer_quat_cs(o2,o1,cs,ss).';   
  else 
    d = dot_outer_quat_cs(o1,o2,cs,ss);  
  end    
  
else
  
  if check_option(varargin,'all')
    d = dot_outer(g1,symmetrise(g2,cs,ss).');
    d = reshape(d,length(g1),length(g2),[]);
  elseif (l1 < l2) && (l1>0)
    d = dot_outer_i(o2,o1,cs,ss).';   
  else 
    d = dot_outer_i(o1,o2,cs,ss);  
  end    
  
end

% ensure dot product is in [-1,1]
d = max(min(d,1),-1);

end

function d = dot_outer_quat(g1,g2)
% quick version that ignores inversion

q1 = [g1.a(:) g1.b(:) g1.c(:) g1.d(:)];
q2 = [g2.a(:) g2.b(:) g2.c(:) g2.d(:)];
  
% this is implicite dot_outer
d = abs(q1 * q2.'); 

end


function d = dot_outer_quat_cs(g1,g2,cs,ss)
% quick version that ignores inversion

g2rot = symmetrise(quaternion(g2),cs,ss).'; % g2 x CS x SS

q1 = [g1.a(:) g1.b(:) g1.c(:) g1.d(:)];
a2 = g2rot.a; b2 = g2rot.b; c2 = g2rot.c; d2 = g2rot.d;
  
% this is implicite dot_outer
d = abs(q1 * [a2(:,1).';b2(:,1).';c2(:,1).';d2(:,1).']); 
for k= 2 : size(a2,2)
  d = max(d,abs(q1 * [a2(:,k).';b2(:,k).';c2(:,k).';d2(:,k).'])); % g1 x g2 x CS * SS
end

end

function d = dot_outer_i(g1,g2,cs,ss)
% quick version that includes inversion

g2rot = symmetrise(g2,cs,ss).'; % g2 x CS x SS

q1 = [g1.a(:) g1.b(:) g1.c(:) g1.d(:)];
i1 = g1.i(:);

a2 = g2rot.a; b2 = g2rot.b; c2 = g2rot.c; d2 = g2rot.d;
i2 = g2rot.i;

% this is implicite dot_outer
d = ~bsxfun(@xor,i1,i2(:,1).' .* ...
  abs(q1 * [a2(:,1).';b2(:,1).';c2(:,1).';d2(:,1).']));

for k=2 : size(a2,2)  
  d = max(d,...                       % g1 x g2 x CS * SS
    ~bsxfun(@xor,i1,i2(:,k).' .* ...
    abs(q1 * [a2(:,k).';b2(:,k).';c2(:,k).';d2(:,k).']))); 
end

end
