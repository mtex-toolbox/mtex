function [totfreq, bc, azi]=calcTDF(g,varargin)
% calc circular axis/ trend distribution function of grain long axes
% OR grain boundary segments or from a list of angles for axial data (0:pi)
%
% Syntax:
%  [freq,bc] = calcTDF(smoothgrains.boundary('indexed'))
%  or
%  [freq,bc] = calcTDF(smoothgrains('indexed'))
%
% Input
%  gb          -  @grainBoundary
%  grains      -  @grains
%  azi         -  angle in radians
%
% Output
%  totfreq     - population density of bin (radius)
%  bc          - center of bin (angle)
%  azi         - list of all azimuth/trends
%
% Options
%  binwidth    - angular binwith in radian (keyword,value)
%  freq        - instead of length, do frequencies only
%  weights     - instead of length, use weights
%
%
% Note: In case of boundaries, this function only makes sense for smoothed
%  boundaries and one would potentially remove grains touching the
%  edge of the map unless only indexed-phase gbs are considered!



% get options
% get binwidth and accordingly bin edges
bw = get_option(varargin,'binwidth',1*degree);
edges = linspace(0,pi,round(pi/bw)); % half circle

% check input and and get data, try to extract weights anyways
if isa(g,'numeric')
    % accept list of angles
    azi = g;
    wlen = ones(size(g));
end
if isa(g, 'grain2d')
    [azi,wlen,~]=principalComponents(g,'hull');
    % sometimes wlne is a complex
    wlen=real(wlen);
    % note: maybe something more conservative like grain.diameter might
    % be good
    %wlen=g.diameter;
    
end
if isa(g,'grainBoundary') % check for grain boundaries
    %get the grain boundary directions
    gb_dir=g.direction;
    %get the segment lengths
    wlen = g.segLength;
    % kill nans
    nanid=isnan(gb_dir.x);
    gb_dir(nanid)=[];
    wlen(nanid)=[];
    %get gb trace direction
    azi=atan(gb_dir.y./gb_dir.x);
end
%azi should go from 0 at east ccw - because I like it like that
azi(azi<0)=azi(azi<0)+pi;
azi=mod(azi,pi);

if check_option(varargin,'weights') %get weights in case given
    wlen = get_option(varargin,'weights');
end


if ~check_option(varargin,'freq')
    [~,azibin] = histc(azi,edges);
    % use indexes in azibin to add gb_lenght into each bin
    totfreq = accumarray(azibin,wlen,[numel(edges)-1 1]); 
else                                % simple counting, no weights
    totfreq = histc(azi,edges);
    totfreq(end)=[]; % will be empty
end

% prep output
totfreq= [totfreq; totfreq]; % repeat it to make full circle becasue it pleases the eye
totfreq(end+1) = totfreq(1);   % append the first value at the end to make it round

% bincenters all around
bc = edges+bw/2; bc = [bc(1:end-1) bc(1:end-1)+pi];
bc(end+1)=bc(1);
bc = bc';
end
