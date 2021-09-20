function varargout=hist2d(x,y,varargin)
%HIST2D Bivariable histogram plot
%	HIST2D(X,Y) creates a bivariate histogram plot of vectors X and Y.
%
%	The function uses an automatic binning algorithm that returns bins with
%	a uniform area, chosen to cover the range of elements in X and Y and 
%	reveal the underlying shape of the distribution. HIST2D without output
%	argument displays the bins as 3-D rectangular bars such that the height
%	of each bar indicates the number of elements in the bin.
%
%	HIST2D(X,Y,NBINS) specifies the number of bins to use in each dimension
%	of the histogram (default is 10).
%
%	HIST2D(X,Y,Xedges,Yedges) specifies the edges of the bins in each 
%	dimension using the vectors Xedges and Yedges.
%
%	HIST2D(...,'tile') plots the result as a tiled 2-D image.
%
%	HIST2D(...,'bar3') plots the result as a 3-D bars. This is the default
%	graph output but without this option, it will automatically switch to
%	2-D if the number of total bins exceeds 2500 (e.g. 50x50).
%
%	N = HIST2D(...) returns the bin counts matrix N of size MxP where M is
%	number of bins for Y and P the number of bins for X. No graph produced.
%	Add 'bar3' or 'tile' option to force the graph.
%
%	[N,Xbins,Ybins] = HIST2D(...) returns also the two bins vectors.
%
%	It is also possible to normalize the bin counts matrix:
%
%	HIST2D(...,'probability') normalizes bin counts as a probability. The 
%	height of each bar is the relative number of observations (number of 
%	observations in bin / total number of observations). The sum of the bar
%	heights is 1.
%
%	HIST2D(...,'countdensity') normalizes bin counts as count density. The 
%	height of each bar is (number of observations in bin) / (area of bin). 
%	The volume (height * area) of each bar is the number of observations 
%	in the bin. The sum of the bar volumes is equal to numel(X) and numel(Y).
%
%	HIST2D(...,'pdf') normalizes bin counts as probability density function.
%	The height of each bar is (number of observations in the bin) / (total 
%	number of observations * area of bin). The volume of each bar is the 
%	relative number of observations. The sum of the bar volumes is 1.
%
%	HIST2D(...,'cumcount') normalizes bin counts as cumulative counts. The 
%	height of each bar is the cumulative number of observations in each bin
%	and all previous bins in both the X and Y dimensions. The height of the
%	last bar is equal to numel(X) and numel(Y).
%
%	HIST2D(...,'cdf') normalizes bin counts as cumulative density function. 
%	The height of each bar is equal to the cumulative relative number of 
%	observations in each bin and all previous bins in both the X and Y 
%	dimensions. The height of the last bar is 1.
%
%
%	Example:
%		x = randn(1000,1);
%		y = randn(1000,1);
%		hist2d(x,y)
%
%
%	Author: Francois Beauducel <beauducel@ipgp.fr>
%	Created: 2018-03-24 in Yogyakarta, Indonesia
%	Updated: 2021-01-08

%	Copyright (c) 2018-2021, François Beauducel, covered by BSD License.
%	All rights reserved.
%
%	Redistribution and use in source and binary forms, with or without 
%	modification, are permitted provided that the following conditions are 
%	met:
%
%	   * Redistributions of source code must retain the above copyright 
%	     notice, this list of conditions and the following disclaimer.
%	   * Redistributions in binary form must reproduce the above copyright 
%	     notice, this list of conditions and the following disclaimer in 
%	     the documentation and/or other materials provided with the distribution
%	                           
%	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
%	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
%	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
%	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
%	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
%	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
%	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
%	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
%	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
%	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
%	POSSIBILITY OF SUCH DAMAGE.

if nargin < 2
	error('Not enough input variable.')
end

if ~isvector(x) || ~isvector(y) || numel(x) ~= numel(y)
	error('X and Y must be vectors of the same length.')
end

if nargin > 2 && isscalar(varargin{1}) && round(varargin{1}) > 0
	nbins = round(varargin{1});
else
	nbins = 10;
end

if nargin > 3 && isnumeric(varargin{1}) && isvector(varargin{1}) ...
		      && isnumeric(varargin{2}) && isvector(varargin{2})
	xedges = varargin{1};
	yedges = varargin{2};
else
	xedges = linspace(min(x),max(x),nbins+1);
	yedges = linspace(min(y),max(y),nbins+1);
end

% plot options flag
plot_bar3 = any(strcmpi(varargin,'bar3'));
plot_tile = any(strcmpi(varargin,'tile'));

% computes bins vectors (as middle of each edges couples)
xbins = mean(cat(1,xedges(1:end-1),xedges(2:end)));
ybins = mean(cat(1,yedges(1:end-1),yedges(2:end)));

% computes bins width vectors and area matrix
xbw = diff(xedges);
ybw = diff(yedges);
[xx,yy] = meshgrid(xbw,ybw);
a = xx.*yy;

% initiate the result matrix
n = zeros(length(ybins),length(xbins));

% main loop to fill the matrix with element counts
for i = 1:size(n,1)
	k = find(y >= yedges(i) & y < yedges(i+1));
	for j = 1:size(n,2)
		n(i,j) = length(find(x(k) >= xedges(j) & x(k) < xedges(j+1)));
	end
end

% normalize options
if any(strcmpi(varargin,'countdensity'))
	n = n./a;
elseif any(strcmpi(varargin,'cumcount'))
	n = cumsum(cumsum(n,1),2);
elseif any(strcmpi(varargin,'probability'))
	n = n/sum(n(:));
elseif any(strcmpi(varargin,'pdf'))
	n = n./a/sum(n(:));
elseif any(strcmpi(varargin,'cdf'))
	n = cumsum(cumsum(n,1),2)/sum(n(:));	
end

% plots a 3-D graph with indexed colors
if nargout < 1 || plot_bar3 || plot_tile
	if plot_tile || (numel(n) > 2500 && ~plot_bar3)
		imagesc(xbins,ybins,n)
		hold on
		plot(x,y,'.k','MarkerSize',10)
		hold off
	else
		% unit cube XYZ coordinates for patch
		ux = [0 1 1 0 0 0;1 1 0 0 1 1;1 1 0 0 1 1;0 1 1 0 0 0];
		uy = [0 0 1 1 0 0;0 1 1 0 0 0;0 1 1 0 1 1;0 0 1 1 1 1];
		uz = [0 0 0 0 0 1;0 0 0 0 0 1;1 1 1 1 0 1;1 1 1 1 0 1];

		if ~ishold
			cla
		end
		for i = 1:size(n,1)
			for j = 1:size(n,2)
				patch(ux*xbw(j) + xedges(j), ...
					  uy*ybw(i) + yedges(i), ...
					  uz*n(i,j),repmat(n(i,j)/max(n(:)),size(ux)))
			end
		end
		axis tight
		view(3)
		rotate3d on
	end
end

if nargout > 0
	varargout{1} = n;
end

if nargout > 2
	varargout{2} = xbins;
	varargout{3} = ybins;
end
