function f = eval(odf,g,varargin)
% evaluate an odf at orientation g
%
%
%% Input
%  odf - @ODF
%  g   - @orientation
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

if isa(g,'orientation') && odf(1).CS ~= get(g,'CS') && odf(1).SS ~= get(g,'SS')
  warning('symmetry missmatch'); %#ok<WNTAG>
end
f = zeros(size(g));

for i = 1:length(odf)
  
  if check_option(odf(i),'UNIFORM') % uniform portion
    
    f = f + odf(i).c;
  
  elseif check_option(varargin,'FOURIER') || check_option(odf(i),'FOURIER') 
    
    f = f + reshape(eval_fourier(odf(i),g,varargin{:}),...
      size(f));
    
  elseif check_option(odf(i),'FIBRE') % fibre symmetric portion
     
    f = f + reshape(RK(odf(i).psi,g(:),...
      vector3d(odf(i).center{1}),odf(i).center{2},...
      odf(i).c,odf(i).CS,odf(i).SS,1),size(f));
      
  elseif check_option(odf(i),'Bingham')
    
    
    %warning('MTEX:Bingham','Normalization missing!')
    ASym = quaternion(symmetrise(odf(i).center));
    
    C = odf(i).c(1) ./ mhyper(odf(i).psi);

    for iA = 1:size(ASym,1)
    
      h = dot_outer(quaternion(g),ASym(iA,:)).^2;
      
      h = h * reshape(odf(i).psi,[],1);
      
      f = f + reshape(exp(h) .* C,size(f)) ./ size(ASym,2);
    
    end
    
    
  elseif check_option(varargin,'EVEN')
    
    M = GK(odf(i).psi,g(:),odf(i).center,odf(i).CS,odf(i).SS);
    f = f + M * odf(i).c(:);
       
  else % radially symmetric portion
      
    f = f + reshape(sum_K(odf(i).psi,g,odf(i).center,odf(i).CS,odf(i).SS,...
      odf(i).c(:),varargin{:}),size(f));
    
  end
end
