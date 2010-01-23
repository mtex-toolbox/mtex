function f = eval(odf,g,varargin)
% evaluate an odf at quaternions g
%
%
%% Input
%  odf - @ODF
%  g   - @quaternion or @SO3Grid
%
%% Flags
%  EVEN       - calculate even portion only
%  FOURIER    - use NFSOFT based algorithm
%
%% Output
%  f   - values of the ODF at the orientations g
%
%% See also
% kernel/sum_K kernel/K

if isa(g,'SO3Grid')
  if odf(1).CS ~= getCSym(g) && odf(1).SS ~= getSSym(g)
    warning('symmetry missmatch'); %#ok<WNTAG>
  end
  f = zeros(GridSize(g));
else
  f = zeros(size(g));
end

for i = 1:length(odf)
  
  if check_option(odf(i),'UNIFORM') % uniform portion
    
    f = f + odf(i).c;
  
  elseif check_option(varargin,'FOURIER') || check_option(odf(i),'FOURIER') 
    
    f = f + reshape(eval_fourier(odf(i),quaternion(g),varargin{:}),...
      size(f));
    
  elseif check_option(odf(i),'FIBRE') % fibre symmetric portion
     
    f = f + reshape(RK(odf(i).psi,reshape(quaternion(g),[],1),...
      vector3d(odf(i).center{1}),odf(i).center{2},...
      odf(i).c,odf(i).CS,odf(i).SS,1),size(f));
      
  elseif check_option(odf(i),'Bingham')
    
    
    %warning('MTEX:Bingham','Normalization missing!')
    ASym = symmetrise(quaternion(odf(i).center,odf(i).CS,odf(i).SS));
    
    C = odf(i).c(1) ./ mhyper(odf(i).psi);

    for iA = 1:size(ASym,2)
    
      h = dot_outer_noabs(quaternion(g),ASym(:,iA)).^2;
      
      h = h * reshape(odf(i).psi,[],1);
      
      f = f + reshape(exp(h) .* C,size(f)) ./ size(ASym,2);
    
    end
    
    
  elseif check_option(varargin,'EVEN')
    
    M = GK(odf(i).psi,reshape(quaternion(g),[],1),...
      quaternion(odf(i).center),odf(i).CS,odf(i).SS);
    f = f + M * odf(i).c(:);
       
  else % radially symmetric portion
      
    f = f + reshape(sum_K(odf(i).psi,g,odf(i).center,odf(i).CS,odf(i).SS,...
      odf(i).c(:),varargin{:}),size(f));
    
  end
end
