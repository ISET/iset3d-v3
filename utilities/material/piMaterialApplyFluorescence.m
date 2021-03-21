function mat = piMaterialApplyFluorescence(mat, varargin)
%%
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('mat', @isstruct);
p.addParameter('type', 'add', @ischar);
p.addParameter('fluoname', 'protoporphyrin', @ischar);
p.addParameter('concentration', rand(1), @isnumeric);

p.parse(mat, varargin{:});
type = p.Results.type;
fluoname = p.Results.fluoname;
concentration = p.Results.concentration;
%%
eemNewFluo = piMaterialGenerateEEM(fluoname);

curEEM = piMaterialGet(mat, 'fluorescence val');
curCon = piMaterialGet(mat, 'concentration val');
if isempty(curEEM)
    eem = eemNewFluo;
else
    [curEEMMatrix, wave] = piVec2EEM(curEEM);
    curEEMMatrix = curEEMMatrix * curCon;
    eemNewFluoMatrix = piVec2EEM(eemNewFluo) * concentration;
    switch type
        case 'add'
            eem = piEEM2Vec(wave, curEEMMatrix + eemNewFluoMatrix);
        case 'subtract'
            eem = piEEM2Vec(wave, curEEMMatrix - eemNewFluoMatrix);
        otherwise
            error('Unknown type: %s', type);
    end
    concentration = 1;
end
mat = piMaterialSet(mat, 'fluorescence val', eem);
mat = piMaterialSet(mat, 'concentration val', concentration);

end