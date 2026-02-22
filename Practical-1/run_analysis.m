% =========================================================================
% Practical 1: 2D Convolution Analysis
% =========================================================================
%
% GROUP NUMBER:
%
% MEMBERS:
%   - Member 1 Name, Student Number
%   - Member 2 Name, Student Number


%% ========================================================================
%  PART 3: Testing and Analysis
%  ========================================================================
%
% Compare the performance of manual 2D convolution (my_conv2) with MATLAB's
% built-in conv2 function (inbuilt_conv2).

function run_analysis()
    % TODO1:
    % Load all the sample images from the 'sample_images' folder
    num_images = size(dir('sample_images/*.png'), 1); % Assuming images are in JPG format
    image_array = {num_images}; % Initialize an array to store images
    image_sizes = {'128x128', '256x256', '512x512', '1024x1024', '2048x2048'};

    for i = 1:num_images
        image_array{i} = imread(sprintf('sample_images/image_%s.png', image_sizes{i})); % Load each image
    end
    
    % TODO2:
    % Define edge detection kernels (Sobel kernel)
    Gx = [-1 0 1; -2 0 2; -1 0 1]; % Sobel kernel for horizontal edges
    Gy = [1 2 1; 0 0 0; -1 -2 -1]; % Sobel kernel for vertical edges
    
    % TODO3:
    % For each image, perform the following:
    %   a. Measure execution time of my_conv2
    %   b. Measure execution time of inbuilt_conv2
    %   c. Compute speedup ratio
    %   d. Verify output correctness (compare results)
    %   e. Store results (image name, time_manual, time_builtin, speedup)
    %   f. Plot and compare results
    %   g. Visualise the edge detection results(Optional)

    % Warm up the functions to ensure fair timing
    for i = 1:5
        for j = 1:num_images
            my_conv2(image_array{j}, Gx, Gy); % Warm up manual convolution
            inbuilt_conv2(image_array{j}, Gx, Gy); % Warm up built-in convolution
        end
    end

    % Initialize arrays to store results
    time_manual = zeros(1, num_images);
    time_builtin = zeros(1, num_images);
    output_manual = zeros(1, num_images);
    output_builtin = zeros(1, num_images);
    speedup = zeros(1, num_images);

    for i = 1:num_images
        % Measure time for manual convolution
        tic;
        output_manual(i) = my_conv2(image_array{i}, Gx, Gy);
        time_manual(i) = toc;

        % Measure time for built in convolution
        tic;
        output_builtin(i) = inbuilt_conv2(image_array{i}, Gx, Gy);
        time_builtin(i) = toc;

        % Compute speedup
        speedup(i) = time_manual(i) / time_builtin(i);
    end
    
    results = table(image_sizes', time_manual', time_builtin', speedup', ...
                    'VariableNames', {'Image_Size', 'Time_Manual', 'Time_Builtin', 'Speedup'});
  
    disp(results);
end


%% ========================================================================
%  PART 1: Manual 2D Convolution Implementation
%  ========================================================================
%
% REQUIREMENT: You may NOT use built-in convolution functions (conv2, imfilter, etc.)

% TODO: Implement manual 2D convolution using Sobel Operator(Gx and Gy)
% output - Convolved image result (grayscale)
function output = my_conv2(varargin) %Add necessary input arguments

end

%% ========================================================================
%  PART 2: Built-in 2D Convolution Implementation
%  ========================================================================
%   
% REQUIREMENT: You MUST use the built-in conv2 function

% TODO: Use conv2 to perform 2D convolution
% output - Convolved image result (grayscale)
function output = inbuilt_conv2(varargin) %Add necessary input arguments

end
