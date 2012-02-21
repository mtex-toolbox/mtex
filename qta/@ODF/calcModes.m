function [modes, values] = calcModes(odf,varargin)
% heuristic to find modal orientations
%
%% Input
%  odf - @ODF 
%  n   - number of modes (not yet supported)
%
%% Output
%  modes - modal @orientation
%  values - values of the ODF at the modal @orientation
%
%% Options
%  resolution  - search--grid resolution
%  accuracy    - in radians
%
%% Example
%  find the local maxima of the [[SantaFe.html,SantaFe]] ODF
%
%    mode = calcModes(SantaFe)
%    plotpdf(SantaFe,Miller(0,0,1))
%    annotate(mode)
%
%
%% See also
% ODF/max

% initial resolution
res = 5*degree;

% target resolution
targetRes = get_option(varargin,'resolution',0.25*degree);

% initial seed
ori = orientation(odf(1).CS,odf(1).SS);
S3G = orientation(odf(1).CS,odf(1).SS);
for i = 1:length(odf) 
  
  switch ODF_type(odf(i).options{:})
  
    case 'UNIFORM' % uniform portion
    
    case 'FOURIER'
    
      S3G = SO3Grid(res,odf(1).CS,odf(1).SS);
          
    case'FIBRE' % fibre symmetric portion
     
      ori = [ori;orientation('fibre',...
        odf(i).center{1},odf(i).center{2},odf(1).CS,odf(1).SS,'resolution',res)]; %#ok<AGROW>
      
    case 'Bingham'
   
      ori = [ori;orientation(odf(i).center(:),odf(1).CS,odf(1).SS)]; %#ok<AGROW>
      S3G = SO3Grid(res,odf(1).CS,odf(1).SS);
       
    otherwise % radially symmetric portion
      
      center = odf(i).center(odf(i).c>=quantile(odf(i).c,-20));
      ori = [ori;center(:)]; %#ok<AGROW>
           
  end
end

% the search grid
S3G = [orientation(S3G(:)); ori];

% first evaluation
f = eval(odf,S3G,varargin{:}); %#ok<EVLC>

% extract 20 largest values
g0 = S3G(f>=quantile(f,-20));

while res > targetRes

  % new grid
  S3G = [g0(:);orientation(SO3Grid(res/4,odf(1).CS,odf(1).SS,'max_angle',res,'center',g0))];
    
  % evaluate ODF
  f = eval(odf,S3G,varargin{:}); %#ok<EVLC>
  
  % extract largest values
  g0 = S3G(f>=quantile(f,0));
  
  res = res / 2; 
end

[values,ind] = max(f(:));
modes = S3G(ind);
