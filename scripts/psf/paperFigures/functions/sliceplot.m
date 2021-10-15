function h = sliceplot(x,data,configNumbers)

clear X Y
box on


xIndex = 1:size(x,1); % 
configIndex = 1:numel(configNumbers);
[~,Y] = meshgrid(xIndex,configNumbers);
X=x';
z = bsxfun(@(x,f) data(x,f)',xIndex,configIndex.'); 
h = waterfall(X,Y,z,zeros(size(z)))


set(gcf, 'color', [1 1 1])
set(h, 'FaceColor', [55 185 229]/255);
set(h, 'FaceAlpha', 0.8);
set(h, 'EdgeColor', 'k');
%set(h, 'FaceVertexCData', rand(380,1))



view(30.9,21.6)

end