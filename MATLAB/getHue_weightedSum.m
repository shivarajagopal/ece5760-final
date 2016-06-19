function avgHueDeg = getHue_weightedSum(filename, numBuckets, varargin)
%getHue Get the dominant color of an RGB image
%   getHue(img_in, numBuckets) takes in an RGB image, converts it 
%   to HSL space, finds the dominant hue, and then returns the 
%   dominating color as an RGB value. The img_in must be in the 
%   format 640x480x3 uint8.

showPlots = 0;
if (nargin == 3)
    showPlots = varargin{1};
end

img_in = imread(filename);
% Initialize buckets
importanceVec = zeros(1,numBuckets);
C = 1;

% Normalize image to values in [0 1]
img = double(img_in)./255.0;
img_hsl = rgb2hsl(img);

hue = img_hsl(:,:,1);
sat = img_hsl(:,:,2);
lum = img_hsl(:,:,3);
bucket = ceil(hue .* numBuckets);
bucket(bucket == 0) = 1;
importance = ((1.0 - (abs(lum-0.5) .* 2.0)) .* sat) + C;

% Update importanceVec

for i = 1:numBuckets
    importanceVec(i) = sum(importance(bucket==i));
end

% Which bucket was the best?
maxImp = max(importanceVec);
bestbucket = find(importanceVec == maxImp);
importanceSum = importanceVec(bestbucket);

% Sum over weighted average
scale = importance(bucket==bestbucket)/importanceSum;

avgHue = sum(scale .* hue(bucket == bestbucket));

% Set output values for average hue and RGB values
avgHueDeg = round(avgHue * 360);

% Create an RGB representation for avgHue with 100% Sat and 50% Lum
fixedsat = [avgHue 1 0.5];
fixedsatRGB = uint8(hsl2rgb(fixedsat).*255.0);

% Create an image to show in a figure to the user
finalimgHSL = zeros(6,6,3);

for i=1:6
    for j=1:6
        finalimgHSL(i,j,:) = fixedsatRGB;
    end
end
if (showPlots == 1)
    finalimgHSL= uint8(finalimgHSL);
    f1 = figure(1);
    movegui(f1,'west');
    imagesc(img_in)
    title('Original Image');
    f2 = figure(2);
    movegui(f2,'east');
    imagesc(finalimgHSL)
    title('Weighted average over Hue values, Sat and Lum fixed');
elseif (showPlots == 2)
    finalimgHSL= uint8(finalimgHSL);
    f2 = figure(3);
    movegui(f2,'southwest');
    imagesc(finalimgHSL)
    title('Weighted average over Hue values, Sat and Lum fixed');
end

end