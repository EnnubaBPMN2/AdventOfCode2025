# 🐹 Installing Go (Golang) on Windows

## Quick Install

### Option 1: Official Installer (Recommended)

1. **Download Go**:
   - Visit: https://go.dev/dl/
   - Download the Windows installer (`.msi` file)
   - Latest stable version recommended (Go 1.21 or later)

2. **Run the Installer**:
   - Double-click the downloaded `.msi` file
   - Follow the installation wizard
   - Default installation path: `C:\Program Files\Go`

3. **Verify Installation**:
   ```powershell
   # Open a NEW PowerShell window and run:
   go version
   
   # Should output something like: go version go1.21.5 windows/amd64
   ```

### Option 2: Using Chocolatey (Package Manager)

If you have Chocolatey installed:

```powershell
# Run as Administrator
choco install golang -y

# Verify
go version
```

### Option 3: Using Scoop

If you have Scoop installed:

```powershell
scoop install go

# Verify
go version
```

## Post-Installation Setup

### 1. Verify GOPATH (Optional)

```powershell
# Check your Go workspace path
go env GOPATH

# Typically: C:\Users\YourUsername\go
```

### 2. Add to PATH (Usually automatic)

The installer should add Go to your PATH automatically. If not:

1. Open **Environment Variables**:
   - Press `Win + X`, select "System"
   - Click "Advanced system settings"
   - Click "Environment Variables"

2. Add to User PATH:
   - Under "User variables", find `Path`
   - Click "Edit"
   - Add: `C:\Program Files\Go\bin`
   - Click OK

3. **Restart your terminal** for changes to take effect

## Running Your First Go Program

```powershell
# Navigate to the AocGo directory
cd C:\Users\HermannRosch\source\repos\EnnubaBPMN2\AdventOfCode2025\AocGo

# Initialize module (if not done)
go mod tidy

# Run the program
go run main.go

# Enter day number when prompted (e.g., 1)
```

## Troubleshooting

### "go: The term 'go' is not recognized"

**Solution**: Restart your terminal/PowerShell after installation. Windows needs to reload the PATH variable.

### Build Errors

```powershell
# Clean the module cache
go clean -modcache

# Re-download dependencies
go mod tidy
```

### Permission Issues

If you get permission errors, run PowerShell as Administrator.

## IDE Support

### Visual Studio Code (Recommended)

1. Install the **Go extension** by Go Team at Google
2. Open the `AocGo` folder in VS Code
3. The extension will prompt to install Go tools - click "Install All"

### GoLand (JetBrains)

- Full-featured IDE specifically for Go
- Free for students and open-source projects
- Download: https://www.jetbrains.com/go/

## Useful Go Commands

```powershell
# Run without building
go run main.go

# Build executable
go build -o aoc.exe

# Run tests
go test ./...

# Format code
go fmt ./...

# Download dependencies
go mod tidy

# Check for updates
go get -u ./...

# Build for release (optimized)
go build -ldflags="-s -w" -o aoc.exe
```

## Next Steps

Once Go is installed:

1. Navigate to `AocGo` directory
2. Run `go mod tidy` to initialize
3. Run `go run main.go` to execute Day 1
4. Start implementing Day 2!

## Resources

- [Official Go Documentation](https://go.dev/doc/)
- [Tour of Go](https://go.dev/tour/) - Interactive tutorial
- [Go by Example](https://gobyexample.com/) - Practical examples
- [Effective Go](https://go.dev/doc/effective_go) - Best practices
