function properties = piMaterialProperties(materialType)
% Return the properties of a particular material type
%
% Synopsis
%   properties = piMaterialProperties(materialType)
%
% Input
%   materialType:   See the possible material types using
%      piMaterialCreate('list available types') 
%
% Optional key/val
%   N/A
%
% Return
%   properties:  Cell array of material properties
%
% See also
%   piMaterialCreate
%

%{
materialType = 'disney';
piMaterialProperties(materialType)

materialType = 'hair';
piMaterialProperties(materialType)

%}
    
allTypes = piMaterialCreate('list available types');
ii =  find(contains(allTypes,materialType));  %#ok<EFIND>
if isempty(ii)
    error('No material type called %s\n',materialType);
end

thisMaterial = piMaterialCreate('thisName','type',allTypes{ii});
properties = fieldnames(thisMaterial);

end

