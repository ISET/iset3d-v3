function val = piLightISParamType(str)
%%
% Synopsis:
%   val = piLightIsParamType(str)
%
% Brief description:
%   Check if a string is light property type
%
% Inputs:
%   str - a string
%
% Returns:
%   val - bool

%% parse input
p = inputParser;
p.addRequired('str', @ischar);
p.parse(str);

str = ieParamFormat(str);

%%
paramTypes = {'string', 'float', 'integer', 'point', 'shape', 'bool',...
            'spectrum', 'rgb', 'color'};
val = ismember(str, paramTypes);        
        
end