% =========================================================================
% Practical 2: Mandelbrot-Set Serial vs Parallel Analysis
% =========================================================================
%
% GROUP NUMBER: 10
%
% MEMBERS:
%   - Member 1 Maarij Alam, ALMMOH017
%   - Member 2 Saeed Solomon, SLMMOG032

function run_analysis()
    % all the image resolutions we need to test
    image_sizes = [
        800,  600;    % SVGA
        1280,  720;   % HD
        1920, 1080;   % Full HD
        2048, 1080;   % 2K Cinema
        2560, 1440;   % 2K QHD
        3840, 2160;   % 4K UHD
        5120, 2880;   % 5K
        7680, 4320    % 8K UHD
    ];

    resolution_names = {'SVGA','HD','Full HD','2K Cinema','2K QHD','4K UHD','5K','8K UHD'};
    max_iterations = 1000;
    num_trials     = 5;   % run each test 5 times and average to reduce noise

    % figure out how many physical cores this machine actually has
    cluster     = parcluster('local');
    max_workers = cluster.NumWorkers;
    fprintf('Detected %d maximum workers.\n', max_workers);

    % test even worker counts from 2 up to max e.g. [2 4 6 8 10]
    worker_counts = 2:2:max_workers;
    num_res       = length(image_sizes);
    num_wc        = length(worker_counts);

    % warm up the JIT compiler for serial before timing starts
    % without this the first timed run includes compile time which skews results
    fprintf('Warming up serial JIT...\n');
    mandelbrot_serial(64, 64, 100);

    % measure serial times once and reuse them for all worker count comparisons
    % no point re-running serial 5 times per worker count
    fprintf('\n--- Measuring serial baselines ---\n');
    serial_times = zeros(num_res, 1);
    for r = 1:num_res
        W = image_sizes(r,1);  H = image_sizes(r,2);
        t = zeros(1, num_trials);
        for k = 1:num_trials
            tic; mandelbrot_serial(W, H, max_iterations); t(k) = toc;
        end
        % drop the first trial since JIT may still be warming up
        serial_times(r) = mean(t(2:end));
        fprintf('  %-10s %.4fs\n', resolution_names{r}, serial_times(r));
    end

    % preallocate storage for results
    all_parallel = zeros(num_res, num_wc);
    all_speedup  = zeros(num_res, num_wc);

    % cache the validation results so we only compute them once
    % (output doesnt change between worker counts, same math either way)
    valid_cache = cell(num_res, 1);

    % main loop - test each worker count
    for wi = 1:num_wc
        nw = worker_counts(wi);
        fprintf('\n=== %d workers ===\n', nw);

        % restart the pool at the right size for this iteration
        p = gcp('nocreate');
        if ~isempty(p); delete(p); end
        parpool('local', nw);

        % warm up the parallel JIT for this pool size as well
        mandelbrot_parallel(64, 64, 100);

        % time parallel for each resolution
        for r = 1:num_res
            W = image_sizes(r,1);  H = image_sizes(r,2);
            t = zeros(1, num_trials);

            for k = 1:num_trials
                tic; mandelbrot_parallel(W, H, max_iterations); t(k) = toc;
            end

            % drop first trial same as serial
            all_parallel(r, wi) = mean(t(2:end));
            all_speedup(r,  wi) = serial_times(r) / all_parallel(r, wi);

            % only validate on the first worker count pass since the
            % outputs are deterministic - no point checking 5 times
            if wi == 1
                s_img = mandelbrot_serial  (W, H, max_iterations);
                p_img = mandelbrot_parallel(W, H, max_iterations);
                if nnz(s_img - p_img) == 0
                    valid_cache{r} = 'PASS';
                else
                    valid_cache{r} = 'FAIL';
                end
            end
        end

        % print results table for this worker count
        % includes validation column to confirm serial and parallel match
        fprintf('\n%-12s %-12s %-12s %-12s %-12s %-6s\n', ...
            'Resolution','Serial(s)','Parallel(s)','Speedup','Efficiency','Valid');
        fprintf('%s\n', repmat('-',1,74));
        for r = 1:num_res
            eff = (all_speedup(r,wi) / nw) * 100;
            fprintf('%-12s %-12.4f %-12.4f %-12.4f %-12.2f %-6s\n', ...
                resolution_names{r}, serial_times(r), ...
                all_parallel(r,wi), all_speedup(r,wi), eff, valid_cache{r});
        end
        fprintf('%s\n', repmat('-',1,74));

        % only save the mandelbrot images on the last worker count pass
        % the images are identical regardless of worker count so no need
        % to save them multiple times
        if nw == max_workers
            fprintf('\nSaving Mandelbrot plots...\n');
            for r = 1:num_res
                W = image_sizes(r,1);  H = image_sizes(r,2);
                s_img = mandelbrot_serial  (W, H, max_iterations);
                p_img = mandelbrot_parallel(W, H, max_iterations);
                mandelbrot_plot(s_img, p_img, W, H, resolution_names{r});
            end
        end
    end

    % ── Plot 1: Speedup vs Image Size ───────────────────────────────────
    % shows how speedup changes as image gets bigger for each worker count
    megapixels = (image_sizes(:,1) .* image_sizes(:,2)) / 1e6;
    figure('Visible','off');
    hold on;
    colors = lines(num_wc);
    for wi = 1:num_wc
        plot(megapixels, all_speedup(:,wi), '-o', ...
            'LineWidth', 2, 'Color', colors(wi,:), ...
            'DisplayName', sprintf('%d workers', worker_counts(wi)));
    end
    xlabel('Image Size (Megapixels)');
    ylabel('Speedup');
    title('Speedup vs Image Size');
    legend('Location','northwest');
    grid on;
    saveas(gcf, 'speedup_vs_size.png');
    close;

    % ── Plot 2: Speedup vs Worker Count ─────────────────────────────────
    % shows how adding more workers helps (or doesnt) per resolution
    % ideal line shows what perfect linear scaling would look like
    figure('Visible','off');
    hold on;
    colors = lines(num_res);
    for r = 1:num_res
        plot(worker_counts, all_speedup(r,:), '-o', ...
            'LineWidth', 2, 'Color', colors(r,:), ...
            'DisplayName', resolution_names{r});
    end
    plot(worker_counts, worker_counts, '--k', 'LineWidth', 1.5, ...
        'DisplayName', 'Ideal Linear');
    xlabel('Number of Workers');
    ylabel('Speedup');
    title('Speedup vs Worker Count');
    legend('Location','northwest');
    grid on;
    saveas(gcf, 'speedup_vs_workers.png');
    close;

    % ── Plot 3: Parallel Efficiency vs Worker Count ──────────────────────
    % efficiency = speedup / num_workers * 100
    % 100% would mean perfect scaling, in practice its always lower
    figure('Visible','off');
    hold on;
    colors = lines(num_res);
    for r = 1:num_res
        efficiency = (all_speedup(r,:) ./ worker_counts) * 100;
        plot(worker_counts, efficiency, '-o', ...
            'LineWidth', 2, 'Color', colors(r,:), ...
            'DisplayName', resolution_names{r});
    end
    yline(100, '--k', 'Ideal (100%)', 'LineWidth', 1.5);
    xlabel('Number of Workers');
    ylabel('Efficiency (%)');
    title('Parallel Efficiency vs Worker Count');
    legend('Location','northeast');
    grid on;
    saveas(gcf, 'efficiency_vs_workers.png');
    close;

    fprintf('\nAll graphs saved.\n');
end


%% ========================================================================
%  PART 1: Mandelbrot Set Image Plotting and Saving
%  ========================================================================
function mandelbrot_plot(serial_output, parallel_output, width, height, res_name)

    % plot the serial output
    figure('Visible','off');
    imagesc(serial_output);
    colormap(hot);
    colorbar;
    axis image off;
    title(sprintf('Serial Mandelbrot — %s (%dx%d)', res_name, width, height));
    fname = sprintf('mandelbrot_serial_%dx%d.png', width, height);
    saveas(gcf, fname);
    close;

    % plot the parallel output
    figure('Visible','off');
    imagesc(parallel_output);
    colormap(hot);
    colorbar;
    axis image off;
    title(sprintf('Parallel Mandelbrot — %s (%dx%d)', res_name, width, height));
    fname = sprintf('mandelbrot_parallel_%dx%d.png', width, height);
    saveas(gcf, fname);
    close;

    fprintf('  Saved plots for %s\n', res_name);
end





%% ========================================================================
%  PART 2: Serial Mandelbrot Set Computation
%  ========================================================================
function iteration_counts = mandelbrot_serial(width, height, max_iterations)
    iteration_counts = zeros(height, width);

    for py = 1:height                           % outer loop over rows
        y0 = (py / height) * 2.4 - 1.2;        % compute y0 once per row
        for xp = 1:width
            x0 = (xp / width) * 2.5 - 2.0;
            x = 0.0;  y = 0.0;
            iteration = 0;

            while iteration < max_iterations
                x2 = x * x;                     % FIX: cache squares —
                y2 = y * y;                      % avoids recomputing x^2+y^2
                if x2 + y2 > 4.0
                    break;
                end
                y = 2.0 * x * y + y0;           % update y before x (uses old x)
                x = x2 - y2 + x0;
                iteration = iteration + 1;
            end

            iteration_counts(py, xp) = iteration;
        end
    end
end


%% ========================================================================
%  PART 3: Parallel Mandelbrot Set Computation
%  ========================================================================
function iteration_counts = mandelbrot_parallel(width, height, max_iterations)
    % Preallocate the entire matrix to avoid memory reallocation overhead
    iteration_counts = zeros(height, width);
    
    % parfor over rows allows MATLAB to dynamically load-balance
    parfor py = 1:height
        % Calculate y0 once per row
        y0 = (py / height) * 2.4 - 1.2; 
        
        % Preallocate a local row vector to minimize IPC overhead
        local_row = zeros(1, width);
        
        for xp = 1:width
            x0 = (xp / width) * 2.5 - 2.0;
            x = 0.0;  
            y = 0.0;
            iteration = 0;
            
            while iteration < max_iterations
                x2 = x * x;
                y2 = y * y;
                
                if x2 + y2 > 4.0
                    break;
                end
                
                y = 2.0 * x * y + y0;
                x = x2 - y2 + x0;
                iteration = iteration + 1;
            end
            
            % saving the pixel to the local row
            local_row(xp) = iteration;
        end
        
        % completed row into the sliced output matrix
        iteration_counts(py, :) = local_row; 
    end
end
