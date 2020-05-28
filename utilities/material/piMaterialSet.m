function thisR = piMaterialSet(thisR, materialIdx, param, val, varargin)
%% Parse inputs
param = ieParamFormat(param);
varargin = ieParamFormat(varargin);

p = inputParser;
p.addRequired('recipe', @(x)(isa(x, 'recipe')));
p.addRequired('materialIdx');
p.addRequired('param', @ischar);
p.addRequired('val');

p.parse(thisR, materialIdx, param, val, varargin{:});
idx = p.Results.materialIdx;

%% Conditions where we need to convert spectrum from numeric to char
if contains(param, ['spectrum', 'rgb', 'color']) && isnumereic(val)
    val = strrep(strcat('[', num2str(val), ']'), ' ', ' ');
end

%% 
switch param
    case 'eem'
        fluorophoresName = val;
        if isempty(fluorophoresName)
            thisR.materials.list{idx}.photolumifluorescence = '';
            thisR.materials.list{idx}.floatconcentration = [];
        else
            wave = 365:5:705; % By default it is the wavelength range used in pbrt
            fluorophores = fluorophoreRead(fluorophoresName,'wave',wave);
            % Here is the excitation emission matrix
            eem = fluorophoreGet(fluorophores,'eem');
            %{
                 fluorophorePlot(Porphyrins,'donaldson mesh');
            %}
            %{
                 dWave = fluorophoreGet(FAD,'delta wave');
                 wave = fluorophoreGet(FAD,'wave');
                 ex = fluorophoreGet(FAD,'excitation');
                 ieNewGraphWin; 
                 plot(wave,sum(eem)/dWave,'k--',wave,ex/max(ex(:)),'r:')
            %}

            % The data are converted to a vector like this
            flatEEM = eem';
            vec = [wave(1) wave(2)-wave(1) wave(end) flatEEM(:)'];
            thisR.materials.list{idx}.photolumifluorescence = vec;
        end
    case 'concentration'        
        thisR.materials.list{idx}.floatconcentration = val;
        
    otherwise
        thisR.materials.list{idx}.(param) = val;
end