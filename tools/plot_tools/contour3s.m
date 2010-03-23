function contour3s(x,y,z,Z,v,varargin)
% contour-slices 

%% Flag
%  x,y,z,xy,yz,yz,xyz - slicing planes


 nrm = max(Z(:));
 if numel(v) == 1, v = 0:nrm/v:nrm; end
 
 slicetype = get_flag(varargin,{'x','y','z','xy','xz','yz','xyz'},'z');
  
  T = [];
  % contour slice in Z-dir
  if ~isempty(strfind(slicetype,'z'))
    for i=1:size(Z,3)
      C = contourc(y,x,squeeze(Z(:,:,i)),v); 
      C(3,:) = z(i);
      T = [T C];
    end
  end  
  Tp1 = size(T,2);
  
  % contour slice in X-dir
  if ~isempty(strfind(slicetype,'x'))
    for i=1:size(Z,1)
      C = contourc(z,y,squeeze(Z(i,:,:)),v); 
      C(3,:) = x(i);
      T = [T C];
    end
  end  
  Tp2 = size(T,2);
  
  % contour slice in Y-dir
  if ~isempty(strfind(slicetype,'y'))
    for i=1:size(Z,2)
      C = contourc(z,x,squeeze(Z(:,i,:)),v); 
      C(3,:) = y(i);
      T = [T C];
    end
  end
  
  cc = T(2,:);
  pc = 1;
  while true
    np = cc(pc(end));
   	pc(end+1) = pc(end)+np+1;
    if numel(cc) < pc(end), break, end
  end
  I = T(1,pc(1:end-1)); % colors
  
  %rearrange positions
  T([3 1 2],Tp1+1:Tp2) = T(:,Tp1+1:Tp2);
  T([3 2 1],Tp2+1:end) = T(:,Tp2+1:end);
  
  %a linel
  lines = T';
  lines(pc,:) = NaN;
  
  %copy colors
  c = lines(:,1);
  for k=1:numel(pc)-1
    c(pc(k)+1:pc(k+1)-1) = I(k);
  end
  alpha = (c./nrm).^2;
  alpha(~isfinite(alpha)) = 0;
   
  h = patch('Faces',1:size(lines,1),'Vertices',lines,'EdgeColor','flat',...
       'FaceVertexCData',c,'EdgeAlpha','flat','FaceVertexAlphaData',alpha);
     
  set(gcf,'renderer','opengl')
  
  axis equal
  axis ([min(y) max(y) min(x) max(x) min(z) max(z)])
  grid on
       
     
  