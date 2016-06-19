function avgHueDeg = getHue(filename, numBuckets, varargin)
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
C = 1;

% Initialize buckets and boundaries
importanceVec = zeros(1,numBuckets);
bucketBounds = linspace(0,1,numBuckets+1);

% Normalize image to values in [0 1]
img = double(img_in)./255.0;
img_hsl = rgb2hsl(img);

% Vectorize ALL the things
hue = img_hsl(:,:,1);
sat = img_hsl(:,:,2);
lum = img_hsl(:,:,3);

% Get a bucket for each, normalize all the zeros to bucket 1,
bucket = ceil(hue .* numBuckets);
bucket(bucket == 0) = 1; 

% The all-important importance calculation
importance = ((1.0 - (abs(lum-0.5) .* 2.0)) .* sat) + C;

% Update importanceVec
for i = 1:numBuckets
    importanceVec(i) = sum(importance(bucket==i));
end

% Which bucket was the best?
bestbucket = find(importanceVec == max(importanceVec))

% Grab the average hue for the bucket (Heuristic Method)
avgHue = mean([bucketBounds(bestbucket+1) bucketBounds(bestbucket)]);

% Set output as the 
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
finalimgHSL= uint8(finalimgHSL);
if (showPlots == 1)
    f1 = figure(1);
    movegui(f1,'west');
    imagesc(img_in)
    title('Original Image');
    f2 = figure(2);
    movegui(f2,'east');
    imagesc(finalimgHSL)
    title('Weighted average over Hue values, Sat and Lum fixed');
elseif (showPlots == 2)
    f1 = figure(1);
    movegui(f1,'north');
    imagesc(img_in)
    title('Original Image');
    f2 = figure(2);
    movegui(f2,'southeast');
    imagesc(finalimgHSL)
    title('Interpolated Heuristic Hue');
end

end