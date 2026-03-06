% =========================================================================
% Practical 2: Mandelbrot-Set Serial vs Parallel Analysis
% =========================================================================
%
% GROUP NUMBER: 10
%
% MEMBERS:
%   - Member 1 Maarij Alam, ALMMOH017
%   - Member 2 Saeed Solomon, SLMMOG032

%% ========================================================================
%  PART 4: Testing and Analysis
%  ========================================================================
% Compare the performance of serial Mandelbrot set computation
% with parallel Mandelbrot set computation.

function run_analysis()
    image_sizes = [
        [800,600],   %SVGA
        [1280,720],  %HD
        [1920,1080], %Full HD
        [2048,1080], %2K Cinema
        [2560,1440], %2K QHD
        [3840,2160], %4K UHD
        [5120,2880], %5K
        [7680,4320]  %8K UHD
    ];

    resolution_names = {'SVGA','HD','Full HD','2K Cinema','2K QHD','4K UHD','5K','8K UHD'};
    max_iterations = 1000;
    num_workers = 6;

    % FIX 1: Correct pool before timing starts (not inside the loop)
    p = gcp('nocreate');
    if ~isempty(p) && p.NumWorkers ~= num_workers
        delete(p);  % kill wrong-sized pool from previous run
    end
    if isempty(gcp('nocreate'))
        parpool('local', num_workers);  % start correct pool before tic/toc
    end

    results = zeros(length(image_sizes), 4);

    for counter = 1:length(image_sizes)
        width  = image_sizes(counter, 1);
        height = image_sizes(counter, 2);

        fprintf('\nRunning %s (%d x %d)...\n', resolution_names{counter}, width, height);

        % FIX 2: Average over 3 trials to smooth out background noise
        serial_times   = zeros(1,3);
        parallel_times = zeros(1,3);

        for trial = 1:3
            tic;
            serial_output = mandelbrot_serial(width, height, max_iterations);
            serial_times(trial) = toc;
        end

        for trial = 1:3
            tic;
            parallel_output = mandelbrot_parallel(width, height, max_iterations);
            parallel_times(trial) = toc;
        end

        results(counter, 2) = mean(serial_times);
        results(counter, 3) = mean(parallel_times);
        results(counter, 4) = results(counter, 2) / results(counter, 3);

        mandelbrot_plot(serial_output, parallel_output, width, height);
    end

    % Results table
    fprintf('\n============================================================\n');
    fprintf('  BENCHMARK RESULTS (%d workers)\n', num_workers);
    fprintf('============================================================\n');
    fprintf('%-12s %-12s %-12s %-12s %-10s\n', 'Resolution', 'Serial(s)', 'Parallel(s)', 'Speedup', 'Efficiency');
    fprintf('------------------------------------------------------------\n');
    for i = 1:length(image_sizes)
        efficiency = (results(i,4) / num_workers) * 100;
        fprintf('%-12s %-12.4f %-12.4f %-12.4f %.2f%%\n', ...
            resolution_names{i}, results(i,2), results(i,3), results(i,4), efficiency);
    end
    fprintf('============================================================\n');

    % Speedup graph
    figure;
    megapixels = (image_sizes(:,1) .* image_sizes(:,2)) / 1e6;
    plot(megapixels, results(:,4), '-o', 'LineWidth', 2);
    hold on;
    yline(num_workers, '--r', sprintf('Ideal (%d workers)', num_workers));
    xlabel('Image Size (Megapixels)');
    ylabel('Speedup');
    title(sprintf('Speedup vs Image Size (%d workers)', num_workers));
    grid on;
    saveas(gcf, sprintf('speedup_%dworkers.png', num_workers));
    close;
    fprintf('Speedup graph saved.\n');

    
end

%% ========================================================================
%  PART 1: Mandelbrot Set Image Plotting and Saving
%  ========================================================================
%
% TODO: Implement Mandelbrot set plotting and saving function
function mandelbrot_plot(serial_output, parallel_output, width, height) %Add necessary input arguments
    %% ========================================================================
%  PART 1: Mandelbrot Set Image Plotting and Saving
%  ========================================================================
    % --- Plot Serial Output ---
    figure('Visible', 'off');           % don't pop up a window
    imagesc(serial_output);             % display iteration count as colour
    colormap(hot);                      % use 'hot' colourmap (looks good for Mandelbrot)
    colorbar;                           % show colour scale
    axis image off;                     % square pixels, no axes
    title(sprintf('Serial Mandelbrot %d x %d', width, height));
    
    % Save the figure
    filename_serial = sprintf('mandelbrot_serial_%dx%d.png', width, height);
    saveas(gcf, filename_serial);
    close;

    % --- Plot Parallel Output ---
    figure('Visible', 'off');
    imagesc(parallel_output);
    colormap(hot);
    colorbar;
    axis image off;
    title(sprintf('Parallel Mandelbrot %d x %d', width, height));

    filename_parallel = sprintf('mandelbrot_parallel_%dx%d.png', width, height);
    saveas(gcf, filename_parallel);
    close;

    fprintf('Saved: %s and %s\n', filename_serial, filename_parallel);
end


%% ========================================================================
%  PART 2: Serial Mandelbrot Set Computation
%  ========================================================================`
%
%TODO: Implement serial Mandelbrot set computation function
function iteration_counts = mandelbrot_serial(width, height, max_iterations) %Add necessary input arguments 
    
    iteration_counts = zeros(height, width);
    
    for xp = 1:width
        for py = 1:height
            x0 = (xp/width)*2.5 - 2.0;
            y0 = (py/height) * 2.4 -1.2;
            x = 0; y = 0; 
            
            iteration = 0; %making this a temp variable to speed up more
    
            while (iteration < max_iterations) && (x^2 + y^2 <= 4)
                x_next = x^2 - y^2 + x0;
                y_next = 2*x*y + y0;
                x = x_next;
                y = y_next;
                iteration = iteration + 1;
            end
    
            iteration_counts(py, xp) = iteration;
        end
    end

end

%% ========================================================================
%  PART 3: Parallel Mandelbrot Set Computation
%  ========================================================================
%
%TODO: Implement parallel Mandelbrot set computation function
function iteration_counts =mandelbrot_parallel(width, height, max_iterations) %Add necessary input arguments

        
        %code to initialise the parallelism with the workers
        % p = gcp('nocreate');
        % if ~isempty(p) && p.NumWorkers ~= num_workers
        %     delete(p);  % shut down wrong-sized pool
        % end
        % if isempty(gcp('nocreate'))
        %     parpool('local', num_workers);
        % end


        iteration_counts = zeros(height, width); 

        parfor xp = 1:width
            %to fix sliced variable conflict:
            column = zeros(height, 1);
            for py = 1:height
                x0 = (xp/width)*2.5 - 2.0;
                y0 = (py/height) * 2.4 -1.2;
                x = 0; y = 0; 
                iteration = 0; %making this a temp variable to speed up more
    
                while (iteration < max_iterations) && (x^2 + y^2 <= 4)
                    x_next = x^2 - y^2 + x0;
                    y_next = 2*x*y + y0;
                    x = x_next;
                    y = y_next;
                    iteration = iteration + 1;
                end
                column(py) = iteration;
                
            end
            iteration_counts(:, xp) = column;
        end

end