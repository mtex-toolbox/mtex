function value = get(obj,vname)
% get object variable

switch vname
  case fields(obj)
    value = [obj.(vname)];
    
  case 'axesAngle'
    
    a = normalize(obj.axis);
    value(1) = (acos(dot(a(1),a(3)))/ degree);
    value(2) = (acos(dot(a(2),a(3)))/ degree);
    value(3) = (acos(dot(a(1),a(2)))/ degree);
    
  case 'axesLength'
    
    value = norm(obj.axis);
    
  case 'axes*'
    
    abc = obj.axis;
    V  = dot(abc(1),cross(abc(2),abc(3)));
    value(1) = cross(abc(2),abc(3)) ./ V;
    value(2) = cross(abc(3),abc(1)) ./ V;
    value(3) = cross(abc(1),abc(2)) ./ V;
    
  case 'axes'
    
    value = obj.axis;
    
  case {'aufstellung','alignment','convention'}
    
    if any(strcmp(obj.laue,{'-1','2/m','-3','-3m'}))
      abc = normalize(obj.axis);
      abcStar = normalize(get(obj,'axes*'));
      [uabc,ind] = unique([abc,abcStar]);
      
      [y,x] = find(isappr(dot_outer(uabc,[xvector,yvector,zvector]),1));
   
      abcLabel = {'a','b','c','a*','b*','c*'};
      abcLabel = abcLabel(ind);
      xyzLabel = {'x','y','z'};
   
      value = cell(1,min(3,length(x)));
      for i = 1:min(3,length(x))
        value{i} = [xyzLabel{x(i)} '||' abcLabel{y(i)}];
      end
    else
      value = {};
    end
  case 'Laue'
    value = obj.laue;
  otherwise
    error('Unknown field in class symmetry!')
end

