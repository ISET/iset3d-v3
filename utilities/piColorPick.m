function rgb = piColorPick(color)
% choose a pre-defined color or randomly pick one
%
% Syntax:
%   rgb = piColorPick(color)
%
% Description:
%    choose a pre-defined color or randomly pick one.
%
% Inputs:
%    color - String. A string indicating the desired color choice. Options
%            are: Random, White, Black, Red, Blue, Silver, and ''.
%
% Outputs:
%    rgb   - Matrix. A 1x3 Matrix of RGB values indicating the color.
%
% Optional key/value pairs:
%    None.
%

% History:
%    XX/XX/XX  XXX  Created
%    04/01/19  JNM  Documentation pass

if piContains(color, 'random')
    colorlist = {'white', 'black', 'red', 'blue', 'silver', ''};
    index = rand;
% color = colorlist{index};
    if index <= 0.3, color = 'white'; end
    if index > 0.3 && index <= 0.45, color = 'black'; end
    if index > 0.45 && index <= 0.65, color = 'red'; end
    if index > 0.65 && index <= 0.8, color = 'blue'; end
    if index > 0.8 && index <= 0.85, color = 'green'; end
    if index > 0.85 && index <= 0.90, color = 'yellow'; end
    if index > 0.90 && index <= 1, color = 'silver'; end
    rgb = colorswitch(color);
else
    rgb = colorswitch(color);
end

end

function rgb = colorswitch(color)
% Return desired RGB values for requested color.
%
% Syntax:
%   rgb = colorswitch(color)
%
% Description:
%    Return the associated Red, Green, and Blue values that correspond to
%    the provided color string.
%
% Inputs:
%    color - String. A string indicating the desired color.
%
% Outputs:
%    rgb   - Matrix. A 1x3 matrix for the red, green, and blue values.
%
% Optional key/value pairs:
%    None.
%

switch color
    case 'white'
        r = randi(14, 1) + 240;
        g = r;
        b = r;
        rgb = [r/255 g/255 b/255];
    case 'black'
        r = randi(50, 1);
        g = randi(20, 1);
        b = randi(20, 1);
        rgb = [r/255 g/255 b/255];
    case 'red'
        r = randi(50, 1) + 200;
        g = randi(30, 1);
        b = randi(30, 1);
        rgb = [r/255 g/255 b/255];
    case 'blue'
        r = randi(50, 1);
        g = 50 + randi(50, 1);
        b = 205 + randi(50, 1);
        rgb = [r/255 g/255 b/255];
    case 'green'
        r = randi(80, 1);
        g = 120 + randi(80, 1);
        b = randi(80, 1);
        rgb = [r/255 g/255 b/255];
    case 'yellow'
        r = 170 + randi(50, 1);
        g = r-10;
        b = randi(50, 1);
        rgb = [r/255 g/255 b/255];
    case 'silver'
        r = 200;
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
end

end