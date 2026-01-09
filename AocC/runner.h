#ifndef RUNNER_H
#define RUNNER_H

#include <stdint.h>

// Function pointer type for solver functions
typedef int64_t (*SolverFunc)(const char*);

// Run a solution part with test and real inputs
void run_solution(
    const char* part_name,
    SolverFunc solver,
    const char* test_path,
    const char* real_path,
    int64_t expected_test_result
);

#endif // RUNNER_H
