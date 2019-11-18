function contour3s(x,y,z,Z,v,varargin)
% contour-slices 

% Flag
%  contour3
%  surf3
%  slice3
%
%  x,y,z,xy,yz,yz,xyz - slicing planes

%
% plot(SantaFe,'alpha','contour3','xyz','sections',90,'resolution',1*degree)
% plot(SantaFe,'phi1','slice3','xyz')
% plot(SantaFe,'sigma','surf3')


nrm = max(Z(:));
if numel(v) == 1, v = linspace(0,nrm,v); end
 
if check_option(varargin,'contour3')
   
  slicetype = get_flag(varargin,{'x','y','z','xy','xz','yz','xyz'},'z');
  
  T = [];
  % contour slice in Z-dir
  if ~isempty(strfind(slicetype,'z'))
    for i=1:size(Z,3)
      C = contourc(x(1,:,1),y(:,1,1),squeeze(Z(:,:,i)),v); 
      C(3,:) = z(1,1,i);
      T = [T C];
    end
  end
  Tp1 = size(T,2);
  
  % contour slice in X-dir
  if ~isempty(strfind(slicetype,'x'))
    for i=1:size(Z,1)
      C = contourc(z,x,squeeze(Z(i,:,:)),v); 
      C(3,:) = y(i);
      T = [T C];
    end
  end  
  Tp2 = size(T,2);
  
  % contour slice in Y-dir
  if ~isempty(strfind(slicetype,'y'))
    for i=1:size(Z,2)
      C = contourc(z,y,squeeze(Z(:,i,:)),v); 
      C(3,:) = x(i);
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
   
  patch('Faces',1:size(lines,1),'Vertices',lines,'EdgeColor','flat',...
    'FaceVertexCData',c,'EdgeAlpha','flat','FaceVertexAlphaData',alpha);

elseif check_option(varargin,{'surf3','slice3'})
  if check_option(varargin,'surf3')
    cdata = 0;  fac = [NaN NaN NaN]; vert = [0 0 0];

    for k=1:numel(v)
      [faces, verts] = isosurface(x,y,z,Z,v(k));
      fac = [fac; faces+size(vert,1)]; %#ok<*AGROW>
      vert = [vert; verts];    
      cdata = [cdata; v(k).*ones(size(faces,1),1)];
    end
    alpha = cdata./nrm;
    
    patch('vertices',vert,'faces',fac,'CData',cdata,'FaceColor','flat','FaceAlpha','flat','EdgeColor','none','FaceVertexAlphaData',alpha);
  elseif check_option(varargin,'slice3')
    slicetype = get_flag(varargin,{'x','y','z','xy','xz','yz','xyz'},'z');
    
    fpos = -10;
    if ~isempty(strfind(slicetype,'z'))
      fpos = fpos+20;
      h2 = uicontrol(...
        'Units','pixels',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@sliceitz,x,y,z,Z},...
        'Position',[fpos 10 16 120],...
        'Style','slider',...
        'Tag','z');
%       uibutton('Position',[fpos 130 16 20],'String',labelz,'Interpreter','tex')
    end

    if ~isempty(strfind(slicetype,'y'))
      fpos = fpos+20;
      h2 = uicontrol(...
        'Units','pixels',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@sliceity,x,y,z,Z},...
        'Position',[fpos 10 16 120],...
        'Style','slider',...
        'Tag','y');
%     uibutton('Position',[fpos 130 16 20],'String',labely,'Interpreter','tex')

    end
    
    if ~isempty(strfind(slicetype,'x'))
      fpos = fpos+20;
      h2 = uicontrol(...
        'Units','pixels',...
        'BackgroundColor',[0.9 0.9 0.9],...
        'Callback',{@sliceitx,x,y,z,Z},...
        'Position',[fpos 10 16 120],...
        'Style','slider',...
        'Tag','x');
%       uibutton('Position',[fpos 130 16 20],'String',labelx,'Interpreter','tex')

    end
    
    set(gcf,'Toolbar','figure')
    
  end


end
       
%set(gcf,'renderer','opengl')
  
%axis equal
%axis ([min(x(:)) max(x(:)) min(y(:)) max(y(:))  min(z(:)) max(z(:))])
%grid on
  
end

% -----------------------------------------------------------------
function sliceitz(e,c,x,y,z,Z)

fx = get(e,'Value');
[xd, yd, zd] = meshgrid(linspace(0,max(x(:)),numel(x)*2),linspace(0,max(y(:)),numel(y)*2),fx*max(z));
  
if isappdata(gcbo,'slicingz')
  delete(getappdata(gcbo,'slicingz'));
end

hold on,
h = slice(x,y,z,Z,xd,yd,zd);
set(h,'EdgeColor','none');
hold off

setappdata(gcbo,'slicingz',h);  

end

% -----------------------------------------------------------------
function sliceity(e,c,x,y,z,Z)

fx = get(e,'Value');
[xd, zd, yd] = meshgrid(linspace(0,max(x(:)),numel(x)*2),linspace(0,max(z(:)),numel(z)*2),fx*max(y(:)));
  
if isappdata(gcbo,'slicingy')
  delete(getappdata(gcbo,'slicingy'));
end

hold on,
h = slice(x,y,z,Z,xd,yd,zd);
set(h,'EdgeColor','none');
hold off

setappdata(gcbo,'slicingy',h);  

end

% ------------------------------------------------------------------
function sliceitx(e,c,x,y,z,Z)

fx = get(e,'Value');

zd = fx*ones(size(x));
[yd, zd, xd] = meshgrid(linspace(0,max(y(:)),numel(y)*2),linspace(0,max(z(:)),numel(z)*2),fx*max(x(:)));
  
if isappdata(gcbo,'slicingx')
  delete(getappdata(gcbo,'slicingx'));
end

hold on,
h = slice(x,y,z,Z,xd,yd,zd);
set(h,'EdgeColor','none');
hold off

setappdata(gcbo,'slicingx',h);  

end
