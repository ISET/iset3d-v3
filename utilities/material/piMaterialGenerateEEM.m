function val = piMaterialGenerateEEM(fluoname, varargin)
%%
varargin = ieParamFormat(varargin);
p = inputParser;
p.addRequired('fluoname', @ischar);
p.addParameter('wave', 365:5:705, @isnumeric);
p.addParameter('form', 'vec', @ischar);

p.parse(fluoname, varargin{:});
fluoname = p.Results.fluoname;
wave = p.Results.wave;
form = p.Results.form;

%%
val = [];
fluorophore = fluorophoreRead(fluoname, 'wave', wave);
eem = fluorophoreGet(fluorophore, 'eem energy');

if isempty(eem)
    warning('Cannot find fluorophore: %s', fluoname);
    return;
end

switch form
    case {'vec', 'vector'}
        val = piEEM2Vec(wave, eem);
    case {'mat', 'matrix'}
        val = eem;
end
%%
end