function m = piMaterialCreate
% Create a template for the material structure.
%
% Syntax:
%   m = piMaterialCreate
%
% Description:
%    This function creates a template for a material structure.
%    (Initializes all of the required values for a material structure.)
%
%    We have noticed these as possible additions
%        spectrum Kd
%        xyz Kd
%
%    V2 had a specifier 'texture bumpmap' that we don't think is V3.
%
% Inputs:
%    None.
%
% Outputs:
%    m - Struct. A material structure.
%
% Optional key/value pairs:
%    None.
%

% History:
%    XX/XX/XX  XXX  Created
%    04/03/19  JNM  Documentation pass

m.name = '';
m.linenumber = [];

m.string = '';
m.floatindex = [];

m.texturekd = '';
m.texturekr = '';
m.textureks = '';

m.rgbkr =[];
m.rgbks =[];
m.rgbkd =[];
m.rgbkt =[];

m.colorkd = [];
m.colorks = [];
m.colorreflect = [];
m.colortransmit = [];

m.floaturoughness = [];
m.floatvroughness = [];
m.floatroughness =[];
m.spectrumkd = '';
m.spectrumks ='';
m.spectrumk = '';
m.spectrumeta ='';
m.stringnamedmaterial1 = '';
m.stringnamedmaterial2 = '';
m.texturebumpmap = '';

end
