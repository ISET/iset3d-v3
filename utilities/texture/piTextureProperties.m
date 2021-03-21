function properties =  piTextureProperties(textureType)
% List the settable properties for each type of texture
%
% Synopsis
%   properties =  piTextureProperties(textureType)
%
% Input
%
% Optional key/value pairs
%
% Returns
%
% Description
%
%
% See also
%

% Examples:
%{
  tTypes = piTextureCreate('list available types');
  piTextureProperties(tTypes{4})
%}

thisTexture = piTextureCreate('ignoreMe','type',textureType);
properties = fieldnames(thisTexture);

end
