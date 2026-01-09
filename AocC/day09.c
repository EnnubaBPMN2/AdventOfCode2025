#include "day09.h"
#include "runner.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>

void day09_run(void) {
    const char* test_path = "../inputs/day09_test.txt";
    const char* real_path = "../inputs/day09.txt";

    run_solution("Part 1", day09_part1, test_path, real_path, 50);
    run_solution("Part 2", day09_part2, test_path, real_path, 24);
}

typedef struct {
    int x, y;
} Point;

static int direction(Point p1, Point p2, Point p3) {
    int64_t val = (int64_t)(p3.y - p1.y) * (p2.x - p1.x) -
                  (int64_t)(p2.y - p1.y) * (p3.x - p1.x);
    if (val == 0) return 0;
    return (val > 0) ? 1 : -1;
}

static bool segments_properly_intersect(Point p1, Point p2, Point p3, Point p4) {
    int d1 = direction(p3, p4, p1);
    int d2 = direction(p3, p4, p2);
    int d3 = direction(p1, p2, p3);
    int d4 = direction(p1, p2, p4);

    return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
           ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
}

static bool is_point_on_segment(Point p, Point s1, Point s2) {
    if (s1.x == s2.x && s1.x == p.x) {
        int min_y = (s1.y < s2.y) ? s1.y : s2.y;
        int max_y = (s1.y > s2.y) ? s1.y : s2.y;
        return p.y >= min_y && p.y <= max_y;
    }
    if (s1.y == s2.y && s1.y == p.y) {
        int min_x = (s1.x < s2.x) ? s1.x : s2.x;
        int max_x = (s1.x > s2.x) ? s1.x : s2.x;
        return p.x >= min_x && p.x <= max_x;
    }
    return false;
}

static bool is_inside_polygon(Point p, Point* polygon, int n) {
    int intersections = 0;

    for (int i = 0; i < n; i++) {
        Point p1 = polygon[i];
        Point p2 = polygon[(i + 1) % n];

        if ((p1.y > p.y) != (p2.y > p.y)) {
            double intersect_x = (double)(p2.x - p1.x) * (p.y - p1.y) / (p2.y - p1.y) + p1.x;
            if (p.x < intersect_x) {
                intersections++;
            }
        }
    }

    return (intersections % 2) == 1;
}

static bool is_inside_or_on_boundary(Point p, Point* polygon, int n) {
    for (int i = 0; i < n; i++) {
        if (is_point_on_segment(p, polygon[i], polygon[(i + 1) % n])) {
            return true;
        }
    }
    return is_inside_polygon(p, polygon, n);
}

int64_t day09_part1(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    Point points[10000];
    int n = 0;

    char* line = strtok(data, "\r\n");
    while (line && n < 10000) {
        int x, y;
        if (sscanf(line, "%d,%d", &x, &y) == 2) {
            points[n].x = x;
            points[n].y = y;
            n++;
        }
        line = strtok(NULL, "\r\n");
    }

    free(data);

    if (n < 2) return 0;

    int64_t max_area = 0;

    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            int width = abs(points[j].x - points[i].x) + 1;
            int height = abs(points[j].y - points[i].y) + 1;
            int64_t area = (int64_t)width * height;

            if (area > max_area) {
                max_area = area;
            }
        }
    }

    return max_area;
}

int64_t day09_part2(const char* input) {
    char* data = strdup(input);
    if (!data) return 0;

    Point points[10000];
    int n = 0;

    char* line = strtok(data, "\r\n");
    while (line && n < 10000) {
        int x, y;
        if (sscanf(line, "%d,%d", &x, &y) == 2) {
            points[n].x = x;
            points[n].y = y;
            n++;
        }
        line = strtok(NULL, "\r\n");
    }

    free(data);

    if (n < 2) return 0;

    int64_t max_area = 0;

    for (int i = 0; i < n; i++) {
        for (int j = i + 1; j < n; j++) {
            int min_x = (points[i].x < points[j].x) ? points[i].x : points[j].x;
            int max_x = (points[i].x > points[j].x) ? points[i].x : points[j].x;
            int min_y = (points[i].y < points[j].y) ? points[i].y : points[j].y;
            int max_y = (points[i].y > points[j].y) ? points[i].y : points[j].y;

            // Check corners
            Point corners[4] = {
                {min_x, min_y},
                {min_x, max_y},
                {max_x, min_y},
                {max_x, max_y}
            };

            bool all_inside = true;
            for (int c = 0; c < 4; c++) {
                if (!is_inside_or_on_boundary(corners[c], points, n)) {
                    all_inside = false;
                    break;
                }
            }
            if (!all_inside) continue;

            // Check for interior tiles
            bool has_interior = false;
            for (int k = 0; k < n; k++) {
                if (points[k].x > min_x && points[k].x < max_x &&
                    points[k].y > min_y && points[k].y < max_y) {
                    has_interior = true;
                    break;
                }
            }
            if (has_interior) continue;

            // Check for boundary crossings
            bool has_crossing = false;
            Point rect_corners[4] = {
                {min_x, min_y},
                {max_x, min_y},
                {max_x, max_y},
                {min_x, max_y}
            };

            for (int k = 0; k < n && !has_crossing; k++) {
                Point p1 = points[k];
                Point p2 = points[(k + 1) % n];

                for (int r = 0; r < 4; r++) {
                    if (segments_properly_intersect(p1, p2, rect_corners[r], rect_corners[(r + 1) % 4])) {
                        has_crossing = true;
                        break;
                    }
                }
            }

            if (!has_crossing) {
                int64_t width = max_x - min_x + 1;
                int64_t height = max_y - min_y + 1;
                int64_t area = width * height;
                if (area > max_area) {
                    max_area = area;
                }
            }
        }
    }

    return max_area;
}
