// =========================================================================
// Practical 3: Minimum Energy Consumption Freight Route Optimization
// =========================================================================
//
// GROUP NUMBER:
//
// MEMBERS:
//   - Member 1 Maarij Alam, ALMMOH017
//   - Member Saeed Solomon, SLMMOG032

// ========================================================================
//  PART 2: Minimum Energy Consumption Freight Route Optimization using OpenMPI
// =========================================================================


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/time.h>
#include <string.h>
#include <mpi.h>

#define MAX_N 10

// ============================================================================
// Global variables
// ============================================================================

int n; // If this is -1, it signals an error/exit
int adj[MAX_N][MAX_N];

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
  printf("Usage: mpirun -np <num> %s [options]\n", program);
  printf("-i <file>\tInput file name\n");
  printf("-o <file>\tOutput file name\n");
  printf("-h \t\tDisplay this help\n");
}

int best_cost = 1e9;
int best_path[MAX_N];
void branch_and_bound(int current_city, int tree_depth, int current_cost,
                     int visited[MAX_N], int path[MAX_N])
{
    if (tree_depth == n) {
        if (current_cost < best_cost) {
            best_cost = current_cost;
            for (int i = 0; i < n; i++) {
                best_path[i] = path[i];
            }
        }
        return;
    }

    for (int next_city = 0; next_city < n; next_city++) {
        if (!visited[next_city]) {
            int new_cost = current_cost + adj[current_city][next_city];

            if (new_cost < best_cost) {
                visited[next_city] = 1;
                path[tree_depth] = next_city;

                branch_and_bound(next_city, tree_depth + 1,
                                 new_cost, visited, path);

                visited[next_city] = 0; // backtrack
            }
        }
    }
}


int main(int argc, char **argv)
{
    int rank, nprocs;
    int opt;
    int i, j;
    char *input_file = NULL;
    char *output_file = NULL;
    FILE *infile = NULL;
    FILE *outfile = NULL;
    int success_flag = 1; // 1 = good, 0 = error/help encountered

    // Initialize MPI
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &nprocs);


    if (rank == 0) {
        n = -1; 

        while ((opt = getopt(argc, argv, "i:o:h")) != -1)
        {
            switch (opt)
            {
                case 'i':
                    input_file = optarg;
                    break;

                case 'o':
                    output_file = optarg;
                    break;

                case 'h':
                    Usage(argv[0]);
                    success_flag = 0; 
                    break;

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
                fclose(infile);
            }
        }
        if (success_flag) {
            outfile = fopen(output_file, "w");
            if (outfile == NULL) {
                fprintf(stderr, "Error: Cannot open output file '%s'\n", output_file);
                perror("");
                success_flag = 0;
            }
        }

    }


    MPI_Bcast(&n, 1, MPI_INT, 0, MPI_COMM_WORLD);

    
    if (n == -1) {
        MPI_Finalize();
        return 0; 
    }

   

  
    MPI_Bcast(&adj[0][0], MAX_N * MAX_N, MPI_INT, 0, MPI_COMM_WORLD);

    
    printf("Process %d received adjacency matrix:\n", rank);
    for (i = 0; i < n; i++) {
        for (j = 0; j < n; j++) {
            printf("%d ", adj[i][j]);
        }
        printf("\n");
    }
    printf("\n");

        
    // TODO: compute solution to minimum energy consumption problem here and write to output file
    // Be careful on which process rank writes to the output file to avoid conflicts!
    
    // ======================= COMPUTATION START =========================
    double t_start = gettime();

    // Each process explores different second-city branches
    int visited[MAX_N] = {0};
    int path[MAX_N];

    visited[0] = 1;   // Start at city 0
    path[0] = 0;

    // Distribute work across processes
    for (int next_city = 1 + rank; next_city < n; next_city += nprocs)
    {
        int local_visited[MAX_N];
        int local_path[MAX_N];

        memcpy(local_visited, visited, sizeof(visited));
        memcpy(local_path, path, sizeof(path));

        local_visited[next_city] = 1;
        local_path[1] = next_city;

        int cost = adj[0][next_city];

        branch_and_bound(next_city, 2, cost, local_visited, local_path);
    }

    double t_end = gettime();
    double local_time = t_end - t_start;

    // ======================= GATHER RESULTS =========================

    // Gather all best costs at root
    int all_costs[MAX_N];
    MPI_Gather(&best_cost, 1, MPI_INT,
            all_costs, 1, MPI_INT,
            0, MPI_COMM_WORLD);

    // Root finds best process
    int best_rank = 0;
    int global_best_cost = 1e9;

    if (rank == 0)
    {
        for (i = 0; i < nprocs; i++)
        {
            if (all_costs[i] < global_best_cost)
            {
                global_best_cost = all_costs[i];
                best_rank = i;
            }
        }
    }

    // Broadcast best_rank message to all thread
    MPI_Bcast(&best_rank, 1, MPI_INT, 0, MPI_COMM_WORLD);

    // ======================= SEND BEST PATH =========================

    if (rank == best_rank)
    {
        MPI_Send(best_path, n, MPI_INT, 0, 0, MPI_COMM_WORLD);
    }

    // Root receives final answer
    if (rank == 0)
    {
        int final_path[MAX_N];

        if (best_rank == 0)
        {
            memcpy(final_path, best_path, sizeof(best_path));
        }
        else
        {
            MPI_Recv(final_path, n, MPI_INT, best_rank, 0,
                    MPI_COMM_WORLD, MPI_STATUS_IGNORE);
        }

        // Write output
        fprintf(outfile, "Minimum cost: %d\n", global_best_cost);
        fprintf(outfile, "Path: ");
        for (i = 0; i < n; i++)
        {
            fprintf(outfile, "%d ", final_path[i] + 1); // convert to 1-based
        }
        fprintf(outfile, "\n");

        fprintf(outfile, "Computation time: %f seconds\n", local_time);

        fclose(outfile);

        printf("Done. Best cost = %d\n", global_best_cost);
    }

    

    MPI_Finalize();
    return 0;
}