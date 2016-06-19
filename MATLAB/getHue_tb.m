function result = getHue_tb( buckets )
% GETHUE_TB Test bench for the getHue function
%   Runs the getHue function with the specified 
%   number of buckets to see the difference between
%   the two methods of finding the final hue
numTests = 4;
result = zeros(1,numTests);
for i=1:4
    filename = strcat('test',num2str(i));
    filename = strcat(filename, '.jpg');
    avgHue = getHue_weightedSum(filename, buckets, 2);
    testAvg = getHue(filename, buckets, 2);
    diff = abs(avgHue - testAvg);
    result(i) = diff;
    pause
    close all
end

