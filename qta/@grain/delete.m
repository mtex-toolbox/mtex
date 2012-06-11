function grains = delete( grains, property )
% delete a property of grains
%
%% Input
%  grains   - @grain
%  property - field name
%
%% Output
%  grains   - @grain 
%

assert_property(grains,property,'properties');
for k=1:numel(grains)
   grains(k).properties =  rmfield(grains(k).properties, property);
end  

