// =========================================================================
// Practical 3: Minimum Energy Consumption Freight Route Optimization
// =========================================================================
//
// GROUP NUMBER: 10
//
// MEMBERS:
//   - Member 1 Maarij Alam, ALMMOH017
//   - Member 2 Saeed Solomon, SLMMOG032

// ========================================================================
//  PART 1: Minimum Energy Consumption Freight Route Optimization using OpenMP
// =========================================================================


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <omp.h>
#include <limits.h>

#define MAX_N 10

// ============================================================================
// Global variables
// ============================================================================

int procs = 1;

int n;
int adj[MAX_N][MAX_N];

// Global shared variables
int best_cost;
int best_path[MAX_N];

// ============================================================================
// Timer: returns time in seconds
// ============================================================================

double gettime()
{
    struct timeval tv;
    gettimeofday(&tv, NULL);
    return tv.tv_sec + tv.tv_usec / 1000000.0;
}

// ============================================================================
// Usage function
// ============================================================================

void Usage(char *program) {
  printf("Usage: %s [options]\n", program);
  printf("-p <num>\tNumber of processors/threads to use\n");
  printf("-i <file>\tInput file name\n");
  printf("-o <file>\tOutput file name\n");
  printf("-h \t\tDisplay this help\n");
}

void branch_and_bound(int current_city, int tree_depth, int current_cost, int visited[MAX_N], int path[MAX_N] )
{
    // Base case to see if last city has been reached
    if (tree_depth == n) {

        #pragma omp critical
        {
            if (current_cost < best_cost) {
                best_cost = current_cost;
                for (int i = 0; i < n; i++) {
                    best_path[i] = path[i];
                }
            }
        }
        return;
    }

    // Go to next unvisited city
    for (int next_city = 0; next_city < n; next_city++) {
        if (!visited[next_city]) {
            int new_cost = current_cost + adj[current_city][next_city];

            // Prune if new cost is already worse than best cost
            if (new_cost < best_cost) {
                visited[next_city] = 1;
                path[tree_depth] = next_city;

                branch_and_bound(next_city, tree_depth + 1, new_cost, visited, path);

                // Backtrack so other paths from current_city can be explored
                visited[next_city] = 0;
            }
        }
    }
}


int main(int argc, char **argv)
{
    // start init timer
    double t_init_start = gettime();
    
    int opt;
    int i, j;
    char *input_file = NULL;
    char *output_file = NULL;
    FILE *infile = NULL;
    FILE *outfile = NULL;
    int success_flag = 1; // 1 = good, 0 = error/help encountered
    
    

    while ((opt = getopt(argc, argv, "p:i:o:h")) != -1)
    {
        switch (opt)
        {
            case 'p':
            {
                procs = atoi(optarg);
                break;
            }

            case 'i':
            {
                input_file = optarg;
                break;
            }

            case 'o':
            {
                output_file = optarg;
                break;
            }

            case 'h':
            {
                Usage(argv[0]);
                success_flag = 0; 
                break;
            }

        default:
            Usage(argv[0]);
            success_flag = 0; 
        }
    }


    if (success_flag) {
        infile = fopen(input_file, "r");
        if (infile == NULL) {
            fprintf(stderr, "Error: Cannot open input file '%s'\n", input_file);
            perror("");
            success_flag = 0;
        } else {
            fscanf(infile, "%d", &n);

            for (i = 1; i < n; i++)
            {
                for (j = 0; j < i; j++)
                {
                    fscanf(infile, "%d", &adj[i][j]);
                    adj[j][i] = adj[i][j];
                }
            }
        }
    }

    if (success_flag) {
        outfile = fopen(output_file, "a");
        if (outfile == NULL) {
            fprintf(stderr, "Error: Cannot open output file '%s'\n", output_file);
            perror("");
            success_flag = 0;
        }
    }

    if (!success_flag) return 1;

    

    printf("Running with %d processes/threads on a graph with %d nodes\n", procs, n);

    
    // TODO: compute solution to minimum energy consumption problem here and write to outfile
   // Stop init timer and start compute timer
    double t_init_end = gettime();
    double t_init = t_init_end - t_init_start;
    double t_compute_start = gettime();

    // Set number of threads for OpenMP
    omp_set_num_threads(procs);
    best_cost = INT_MAX; // Initialize best cost to a very large number

    #pragma omp parallel
    {

        // Local variables for each thread
        int visited[MAX_N] = {0};
        int path[MAX_N];

        // Starting at city 1
        visited[0] = 1;
        path[0] = 0;

        // Give threads different starting points to explore
        #pragma omp for schedule(dynamic)
        for (int next_city = 1; next_city < n; next_city++) {
            int new_cost = adj[0][next_city];

            if (new_cost < best_cost) {
                visited[next_city] = 1;
                path[1] = next_city;

                branch_and_bound(next_city, 2, new_cost, visited, path);

                // Backtrack so other paths from city 1 can be explored
                visited[next_city] = 0;
            }
        }

    }

    // Stop timer
    double t_compute_end = gettime();
    double t_compute = t_compute_end - t_compute_start;

    // Print timing results to Console
    printf("Initialisation time : %.8f seconds\n", t_init);
    printf("Computation time    : %.8f seconds\n", t_compute);
    printf("Total time          : %.8f seconds\n", t_init + t_compute);

    if (outfile != NULL) {
        fprintf(outfile, "--- Run with %d Threads ---\n", procs);
        fprintf(outfile, "Minimum cost: %d\n", best_cost);
        fprintf(outfile, "Path: ");
        for (i = 0; i < n; i++) {
            fprintf(outfile, "%d ", best_path[i] + 1); // convert to 1-based indexing
        }
        fprintf(outfile, "\n");
        
        // Explicitly print the split timings to the file so you can calculate speedup
        fprintf(outfile, "T_init: %.8f sec | T_comp: %.8f sec\n\n", t_init, t_compute);
        
        fclose(outfile);
    }

    return 0;
}