% =========================================================================
% Practical 1: 2D Convolution Analysis
% =========================================================================
%
% GROUP NUMBER:
%
% MEMBERS:
%   - Member 1 Maarij Alam, ALMMOH017
%   - Member 2 Saeed Solomon, SLMMOG032


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
        image_array{i} = rgb2gray(image_array{i});
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
            my_conv2(image_array{j}, Gx, Gy,'same'); % Warm up manual convolution
            inbuilt_conv2(image_array{j}, Gx, Gy, 'same'); % Warm up built-in convolution
        end
    end

    % Initialize result to store results
    results = struct('image_name', cell(num_images, 1), ...
                    'output_manual', cell(num_images, 1), 'time_manual', cell(num_images, 1), ...
                    'output_builtin', cell(num_images, 1), 'time_builtin', cell(num_images, 1), ...
                    'speedup', cell(num_images, 1), 'is_correct', cell(num_images, 1));

    for i = 1:num_images
        % Measure time for manual convolution
        tic;
        results.output_manual{i} = my_conv2(image_array{i}, Gx, Gy);
        results.time_manual{i}   = toc;

        % Measure time for built in convolution
        tic;
        results.output_builtin{i} = inbuilt_conv2(image_array{i}, Gx, Gy);
        results.time_builtin{i} = toc;

        % Compute speedup
        results.speedup{i} = results.time_manual{i} / results.time_builtin{i};

        % Verify output correctness (using a simple threshold for comparison)
        tolerance = 1e-5; % Set a tolerance level for comparison
        diff = abs(results.output_manual{i} - results.output_builtin{i});
        
        if diff <= tolerance
            results.is_correct{i} = true;
        else
            results.is_correct{i} = false;
        end
    end
    
    results = table(image_sizes', results.output_manual', results.output_builtin',...
                     results.time_manual', results.time_builtin', results.speedup', results.is_correct', ...
                    'VariableNames', {'Image_Size', 'Output_Manual', 'Output_Builtin', 'Time_Manual', ...
                    'Time_Builtin', 'Speedup', 'Is_Correct'});
  
    disp(results);

    % Plot results
    % Extract speedup values and image sizes for plotting
    speedup_values = cell2mat(results.Speedup);
    figure('Name', 'Speedup Comparison', 'NumberTitle', 'off');
    plot(1:num_images, speedup_values, 'b-o', 'LineWidth', 2, 'MarkerSize', 8);
    xlabel('Image Size');
    ylabel('Speedup Ratio (Manual / Built-in)');
    title('Speedup Comparison: Manual vs Built-in Convolution');
    grid on;
    set(gca, 'XTick', 1:num_images, 'XTickLabel', image_sizes);
    legend('Speedup');
end


%% ========================================================================
%  PART 1: Manual 2D Convolution Implementation
%  ========================================================================
%
% REQUIREMENT: You may NOT use built-in convolution functions (conv2, imfilter, etc.)

% TODO: Implement manual 2D convolution using Sobel Operator(Gx and Gy)
% output - Convolved image result (grayscale)
function output = my_conv2(image, Gx, Gy, shape) %Add necessary input arguments
    
    %converting to double
    image = double(image);
    Gx = double(Gx);
    Gy = double(Gy);

    %getting the size of the matrices:
    [M,N] = size(image);
    [m,n] = size(Gx);

    %for convolution need to flip the kernels:
    Gx = rot90(Gx, 2); % Flip the Gx kernel
    Gy = rot90(Gy, 2); % Flip the Gy kernel
    
    %initially assuming full convolution:
    pad_M = m -1;
    pad_N = n - 1;

    padded = padarray(image, [pad_M pad_N], 0 , 'both');

    full_Gx = zeros(M+m-1,N+n-1);
    full_Gy = zeros(M+m-1, N+n-1);

    for i = 1:(M + m - 1)
        for j = 1:(N + n - 1)

            region = padded(i:i+m-1, j:j+n-1);

            full_Gx(i,j) = sum(sum(region .* Gx));
            full_Gy(i,j) = sum(sum(region .* Gy));

        end
    end

    %get the magnitude:
    %using the approximate magnitude method in the brief:
    full_output = abs(full_Gx) + abs(full_Gy);

    %code to handle the output types:
    switch shape

        case 'full'
            output = full_output;
        case 'same'
            %getting the centered data:
            row_start = floor(m/2)+1;
            col_start = floor(n/2)+1;
            
            %output using the centred Gx and Gy
            output = full_output(row_start:row_start+M-1, col_start:col_start+N-1);
            
        case 'valid'
            output = full_output(m:M,n:N);
        otherwise
            error('Invalid shape')
    end
end

%% ========================================================================
%  PART 2: Built-in 2D Convolution Implementation
%  ========================================================================
%   
% REQUIREMENT: You MUST use the built-in conv2 function

% TODO: Use conv2 to perform 2D convolution
% output - Convolved image result (grayscale)
function output = inbuilt_conv2(image, Gx, Gy,shape) %Add necessary input arguments
    
    image = double(image);
    Cx = conv2(image, Gx, shape);
    Cy = conv2(image, Gy, shape);

    %combined:
    output = abs(Cx) + abs(Cy);

end
