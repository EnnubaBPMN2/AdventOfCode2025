package utils

import (
	"os"
	"strings"
)

// ReadInput reads the entire file and returns the trimmed content
func ReadInput(path string) (string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return "", err
	}
	return strings.TrimSpace(string(data)), nil
}
