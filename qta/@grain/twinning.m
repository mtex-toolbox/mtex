function f = twinning(grains,type,varargin)
% experimental special boundaries

% aachen:   '60°/<111>    //   % ! (001) <001>  [001] {001}
% plot(grains,'colorcoding','hkl')
% twinning(grains,'60°/<111>','color','y','linewidth',2)

[phase uphase] = get(grains,'phase');

 
for k=1:length(uphase)
  grains_phase = grains( phase == uphase(k) );
  o = get(grains_phase,'orientation');
  
  pair = pairs(grains_phase);
  
  %some parsing
  if isa(type,'quaternion')
    or = type;
  elseif isa(type,'char')
    %% TODO
    % setup twinning rotations
    t = regexpsplit(type,'[°/<>]');
    t(cellfun('isempty',t))= [];
    
    a = sscanf(t{2}, '%1d');
    a = Miller(vector3d(a),get(o,'CS'));
    axes = vector3d(symmetrise(a));

    omega = str2num(t{1})*degree;
    
    or = axis2quat(axes,omega);

  end

  % the misoriention
  om = o( pair(:,1) ) \ o( pair(:,2) );
  
  delta = get_option(varargin,'delta',2*degree,'double');
  
  ind = false(size(om));
  for l=1:length(or)
    ind = ind | angle(om,or(l)) < delta;
  end
  
  pp = pair(ind,:);
  
  if ~isempty(pp)
    p = polygon( grains_phase ) ;
    plot( p  ,'pair',pp,varargin{:})
  end
  
   h = num2str( size(pp,1)./ size(pair,1)*100,'%4.2f');    
   disp(['  (phase ' num2str(uphase(k)) ') twins: ' h ' %' ])
  
end