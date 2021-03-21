function properties = piLightProperties(lightType)
%  Show the list of properties for a given light type
%
% Synopsis
%    properties = piLightProperties(lightType);
%
% Input
%
% lightType -  Use piLightCreate('list available types') for the possible
%     types.
%
% Optional key/val
%    N/A
%
% Return
%    properties - cell array of light properties
%
% See also
%   piLightCreate

% Examples:
%{
   piLightProperties('spot')
%}
%{
   piLightProperties('goniometric')
%}

%
thisLight = piLightCreate('ignoreMe','type',lightType);
properties = fieldnames(thisLight);

end
