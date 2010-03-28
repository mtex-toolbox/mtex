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
  
  switch ODF_type(odf(i).options{:},varargin{:})
  
    case 'UNIFORM' % uniform portion
    
      f = f + odf(i).c;
  
    case 'FOURIER'
    
      f = f + reshape(eval_fourier(odf(i),g,varargin{:}),...
        size(f));
    
    case'FIBRE' % fibre symmetric portion
     
      f = f + reshape(RK(odf(i).psi,g(:),...
        vector3d(odf(i).center{1}),odf(i).center{2},...
        odf(i).c,odf(i).CS,odf(i).SS,1),size(f));
      
    case 'Bingham'
   
      f = f + reshape(eval_bingham(odf(i),g,varargin{:}),...
        size(f));
      
    case 'EVEN'
    
      M = GK(odf(i).psi,g(:),odf(i).center,odf(i).CS,odf(i).SS);
      f = f + M * odf(i).c(:);
       
    otherwise % radially symmetric portion
      
      f = f + reshape(sum_K(odf(i).psi,g,odf(i).center,odf(i).CS,odf(i).SS,...
        odf(i).c(:),varargin{:}),size(f));
    
  end
end

