function varargout = plotboundary(grains,varargin)
% plot grain boundaries according to neighboured misorientation angle
%
%% Syntax
%  plotboundary(grains)
%
%% Todo
% Coincidence-site lattice classification
% Twinning
%
%% See also
% grain/misorientation

[phase uphase] = get(grains,'phase');

selector(gcf);

p = polygon( grains );

h = plot(p,'color',[0.8 0.8 0.8]);

CS = get(grains,'CS');

for ph=uphase
  %neighboured grains per phase
  ndx = phase == ph;
  grains_phase = grains(ndx);
  
  pair = pairs(grains_phase);
  pair(pair(:,1) == pair(:,2),:) = []; % self reference

  if ~isempty(pair)   

    pair = unique(sort(pair,2),'rows');
      
    % boundary angle
    o = get(grains_phase,'orientation');
    om = o(pair(:,1)) \ o(pair(:,2));
    
    
    quat = find_type(varargin,'quaternion');
    if ~isempty(quat)
    
      o0 = [varargin{quat}];
      
      delta = get_option(varargin,'delta',2*degree,'double');
  
      ind = false(size(om));
      for l=1:length(o0)
        ind = ind | angle(om,o0(l)) < delta;
      end
      
      pair = pair(ind,:);
      
    elseif ~check_option(varargin,'colorcoding')
      
      d = angle( om )./degree;
      pair(:,3) = d;
      
    else
      
      cc = get_option(varargin,'colorcoding');
      
      d = orientation2color(om,cc,varargin{:});
      pair(:,3:5) = d;
            
    end
    
    h(end+1) = plot(p(ndx), 'pair', pair, varargin{:} );    
    
  end
  
end

selector(gcf,grains,p,h);

if check_option(varargin,'colorcoding');
  setappdata(gcf,'CS',CS);
	setappdata(gcf,'r',get_option(varargin,'r',xvector,'vector3d')); 
	setappdata(gcf,'colorcenter',get_option(varargin,'colorcenter',[]));
	setappdata(gcf,'colorcoding',cc);
	setappdata(gcf,'options',extract_option(varargin,'antipodal'));
end

if nargout > 0
  varargout{1} = h;
end
