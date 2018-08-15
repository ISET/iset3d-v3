function rgb = piColorPick(color)
%% choose a pre-defined color or randomly pick one
if contains(color,'random')
    colorlist = {'white','black','red',...
        'blue','silver',''};
    index = rand;
%     color = colorlist{index};
if index  <= 0.2, color = 'white';end
if index>0.2&&index<=0.4, color = 'black';end
if index>0.4&&index<=0.6, color = 'red';end
if index>0.6&&index<=0.8, color = 'blue';end
if index>0.8&&index<=0.84, color = 'silver';end
if index>0.84&&index<=0.88, color = 'grey';end
if index>0.88&&index<=0.91, color = 'green';end
if index>0.91&&index<=0.94, color = 'yellow';end
if index>0.94&&index<=1, color = 'brown';end
     rgb = colorswitch(color);
else
    rgb = colorswitch(color);
end
end

function rgb = colorswitch(color)
switch color
    case 'brown'
        r = 100;
        g = r - 20;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'white'
        r = 254.9;
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'black'
        r = 1;
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'red'
        r = 254.9;
        g = 1;
        b = 1;
        rgb = [r/255 g/255 b/255];
    case 'blue'
        r = 1;
        b = 254.9;
        g = 1;
        rgb = [r/255 g/255 b/255];
    case 'green'
        g = 108;
        r = 11;
        b = 91;
        rgb = [r/255 g/255 b/255];
    case 'yellow'
        r = 254.9;
        g = 254.9;
        b = g-80;
        rgb = [r/255 g/255 b/255];
    case 'silver'
        r = 220;
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
    case 'grey'
        r = 128;
        g = r;
        b = g;
        rgb = [r/255 g/255 b/255];
end
end