function value = get(obj,vname)
% get object variable

switch vname
  case fields(obj)
    value = [obj.(vname)];
    
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
      
      [y,x] = find(isappr(dot_outer([abc,abcStar],[xvector,yvector,zvector]),1));
   
      abcLabel = {'a','b','c','a*','b*','c*'};
      xyzLabel = {'x','y','z'};
   
      value = cell(1,length(x));
      for i = 1:length(x)
        value{i} = [xyzLabel{x(i)} '||' abcLabel{y(i)}];
      end
    else
      value = {};
    end
  otherwise
    error('Unknown field in class symmetry!')
end

