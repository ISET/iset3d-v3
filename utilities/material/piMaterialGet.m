function val = piMaterialGet(material, param, varargin)
% Get the value of a material parameter
%
% Synopsis:
%   val = piMaterialGet(material, param, varargin)
%
% Brief description:
%   Get a material property.
%
% Inputs
%   material    - material struct.
%   param       - property name.
%
% Returns:
%   val         - property value.
%
% Description
%   The different types of materials have different types of properties.
%   The PBRT book describes the material properties.  To see the properties
%   of any specific type of material, you can execute this code:
%
%      piMaterialProperties(materialType)
%
%   The struct that is returned lists the properties available for that
%   material type.  To see a list of material types, use
%
%      piMaterialCreate('list available types')
%
% ZLY, SCIEN, 2020
%
% See also
%   piMaterialProperties, piMaterialCreate

% Examples:
%{
    mat = piMaterialCreate('new material');
    kdType = piMaterialGet(mat, 'kd type');
    kdVal = piMaterialGet(mat, 'kd value');
%}

%% Parse inputs

% check the parameter name and type/val flag
nameTypeVal = strsplit(param, ' ');
pName    = nameTypeVal{1};
if numel(nameTypeVal) > 1
    pTypeVal = nameTypeVal{2};
else
    pTypeVal = '';
end

p = inputParser;
p.addRequired('material', @isstruct);
p.addRequired('param', @ischar);

p.parse(material, param, varargin{:});

%%
val = [];

if isfield(material, pName)
    % If asking name or type, get the param and return.
    if isequal(pName, 'name') || isequal(pName, 'type')
        val = material.(pName);
        return;
    end
    
    % If type and val are both empty, return the parameter struct.  We
    % should expand this out to list the individual parameters that are
    % legitimate.  The materials have lots of parameters not accessible
    % this way (BW).
    if isempty(pTypeVal)
        val = material.(pName);
    elseif isequal(pTypeVal, 'type')
        val = material.(pName).type;
    elseif isequal(pTypeVal, 'value') || isequal(pTypeVal, 'val')
        val = material.(pName).value;
    end    
else
    warning('Parameter: %s does not exist in material type: %s',...
            param, material.type);
end

end