 function sR = horzcat(varargin)
 
 sR = varargin{1};
 
 for n=2:numel(varargin);
   sR.N = [sR.N(:);varargin{n}.N(:)];
   sR.alpha = [sR.alpha(:);varargin{n}.alpha(:)];
 end
  
 end
