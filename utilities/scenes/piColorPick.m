function rgb = piColorPick(color,varargin)
% Choose a pre-defined color or randomly pick one of the list
%
% Syntax
%  rgb = piColorPick(color,varargin)
%
% Description
%   For the moment, there is randomization of the returned color.  We
%   get something in the range.  We are going to create a key/value
%   pair that sets the randomization range or that turns off
%   randomization of the returned color.
%
% Inputs
%    color:  'red','blue','white','black','silver','yellow','random'
%
% Key/value pairs
%     N/A yet
%
% Outputs
%   rgb - red green blue triplet
%
% Zhenyi
%
% See also
%   piMaterialAssign
%


%% Parse

% colorlist = {'white','black','red','blue','silver','yellow'};

%%

if piContains(color,'random')
    % Choose a random color, I guess.
    index = rand;
    
    if index <= 0.3, color = 'white';end
    if index > 0.30 && index <= 0.45, color = 'black';end
    if index > 0.45 && index <= 0.65, color = 'red';end
    if index > 0.65 && index <= 0.80, color = 'blue';end
    if index > 0.80 && index <= 0.85, color = 'green';end
    if index > 0.85 && index <= 0.90, color = 'yellow';end
    if index > 0.90 && index <= 1.00, color = 'silver';end
    rgb = colorswitch(color);
    
else
    rgb = colorswitch(color);
end

end

function rgb = colorswitch(color)
switch color
    case 'white'
        r = randi(14,1)+220;
        g = r;
        b = r;
        rgb = [r/255 g/255 b/255];
    case 'black'
        r = randi(50,1)+20;
        g = randi(20,1)+20;
        b = randi(20,1)+20;
        rgb = [r/255 g/255 b/255];
    case 'red'
        r = randi(50,1)+200;
        g = randi(30,1)+30;
        b = randi(30,1)+30;
        rgb = [r/255 g/255 b/255];
    case 'blue'
        r = randi(50,1)+15;
        g = 50+randi(50,1);
        b = 205+randi(50,1);
        rgb = [r/255 g/255 b/255];
    case 'green'
        r = randi(80,1)+10;
        g = 120+randi(80,1);
        b = randi(80,1)+10;
        rgb = [r/255 g/255 b/255];
    case 'yellow'
        r = 170+randi(50,1);
        g = r-10;
        b = randi(50,1)+15;
        rgb = [r/255 g/255 b/255];
    case 'silver'
        r = randi(20,1)+150;
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
end
end