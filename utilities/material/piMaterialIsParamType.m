function val = piMaterialIsParamType(str)
%%
% Synopsis:
%   val = piMaterialIsParamType(str)
%
% Brief description:
%   Check if a string is material property type
%   
% Inputs:
%   str - a string
%
% Returns:
%   val - bool
%
%

%% parse input
p = inputParser;
p.addRequired('str', @ischar);

p.parse(str);

str = ieParamFormat(str);
%%
paramTypes = {'string', 'texture', 'float', 'spectrum',...
                'rgb', 'color', 'photolumi', 'bool', 'photolumi'};
            
val = ismember(str, paramTypes);
end