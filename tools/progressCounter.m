classdef progressCounter < handle
% display progress
%
% Syntax
%   
%   progress(iter,maxiter)
%   progress

properties
  caption = "progress: "
  numTotal = 0
  prevCharCnt = 0   % number of characters that needs to be erased
  percentDisplayed  % 
  diaryOn = false
  minUpdateInterval = 0.2 % seconds 
  tLastUpdate = []        % tic handle
end

methods

  function this = progressCounter(n,varargin)
    
    this.caption = get_option(varargin,'caption',this.caption);
    this.numTotal = n;
    this.percentDisplayed = -1;
    this.tLastUpdate = tic;

    if n<=1 || check_option(varargin,'silent') || ...
        getMTEXpref("generatingHelpMode") || progressCounter.active
      this.numTotal = 0;
    end
    
    this.diaryOn = get(0,'Diary') == "on";
    
    if this.numTotal > 0 
      progressCounter.active(true);
      if this.diaryOn, diary('off'); end
      fprintf(this.caption)
      fprintf("\n")
      this.prevCharCnt = 1;
      if this.diaryOn, diary('on'); end
    end

  end

  function delete(this)

    if this.numTotal == 0, return; end

    progressCounter.active(false);

    if this.prevCharCnt == 0 || ~isempty(lastwarn)
      return; 
    end

    % remove all written text
    if this.diaryOn, diary('off'); end    
    fprintf([repmat('\b',1, this.prevCharCnt + strlength(this.caption)+1) '\n']);    
    if this.diaryOn, diary('on'); end

  end
  
  function show(this,n)

    if this.numTotal == 0, return; end
  
    np = round(n/this.numTotal*100);

    if n == this.numTotal
      delete(this);
      return
    elseif np < this.percentDisplayed
      this.prevCharCnt = 0;
    elseif np == this.percentDisplayed || ... % nothing has changed
        toc(this.tLastUpdate) < this.minUpdateInterval % or too quick anyway 
      return;
    end
  
    this.percentDisplayed = np;
    this.tLastUpdate = tic;

    s = [int2str(np) '%%\n'];
        
    % turn diary off temporarily
    if this.diaryOn, diary('off'); end
    
    if ~isempty(lastwarn)
      
      if this.diaryOn, diary('off'); end
      fprintf('\n%s',this.caption)
      fprintf("\n")
      this.prevCharCnt = 1;
      if this.diaryOn, diary('on'); end
      lastwarn('');

    end

    fprintf([repmat('\b',1, this.prevCharCnt) s]);
    
    this.prevCharCnt = length(s) - 2; %

    if this.diaryOn, diary('on'); end

  end

end

methods (Static=true, Access = private)

  function tf = active(tf)
    persistent activeFlag

    if nargin == 1
      activeFlag = tf;
    elseif isempty(activeFlag)
      tf = false;
    else
      tf = activeFlag;
    end        
  end 
end

  
   
methods (Static=true)


  function test

    pC = progressCounter(10);
    for k = 1:10
      
      pg2 = progressCounter(10,'caption','sub iter: ');
      for l=1:10
        pause(0.1)
        pg2.show(l)        
        if k == l && k == 5, warning("k==l"); end
      end

      pC.show(k)

    end
  end

  function test2

    pC = progressCounter(81);
    for k = 1:81
      pause(0.0001)
      pC.show(k)

    end
  end


end
end