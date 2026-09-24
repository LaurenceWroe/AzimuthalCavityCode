

% Open the file
fileID = fopen('S11_Check.txt', 'r');

% Skip the header (first 3 rows)
for i = 1:3
    fgetl(fileID);
end

% Read the data (assuming your data is numeric)
data = textscan(fileID, '%f %f %f');

% Close the file
fclose(fileID);

% Convert the cell array to a matrix (if needed)
dataMatrix = cell2mat(data);

figure()
plot(dataMatrix(:,1),sqrt(dataMatrix(:,2).^2+dataMatrix(:,3).^2))

figure(); hold all;
plot(dataMatrix(:,1),dataMatrix(:,2))
plot(dataMatrix(:,1),dataMatrix(:,3))