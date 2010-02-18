function m = vec2Miller(v,CS,varargin)
% vector3d --> Miller-indece 
%% Syntax
%  m = vect2Miller(v,CS)
%
%% Input
%  v - @vector3d
%
%% Output
%  m - @Miller

a = get(CS,'axis');
V  = dot(a(1),cross(a(2),a(3)));
aa = squeeze(double(cross(a(2),a(3)) ./ V));
bb = squeeze(double(cross(a(3),a(1)) ./ V));
cc = squeeze(double(cross(a(1),a(2)) ./ V));

M = [aa,bb,cc];

if check_option(varargin,'approx')

  for iv = 1:numel(v)
  
    mv = M \ squeeze(double(v(iv)));

    % find common divisor
    nz = find(abs(mv)>1/30,1,'first');

    for i = 1:20

      mm = mv / mv(nz) * i;
      e(i) = sum(abs(mm-round(mm)));
  
    end

    j = find(e<10e-2,1,'first');
    
    if ~isempty(j)
      mm = round(mv / abs(mv(nz)) * j);
    else
      mm = [0,0,0];
    end

    m(iv) = Miller(mm(1),mm(2),mm(3),CS);
  end
else
  m = Miller(aa,bb,cc,CS);
end



