# Python Project Structure Guide

This guide shows how to create a modern Python package structure for `MyPythonLib` - a generic Python library intended for PyPI distribution with professional development practices.

## Overview

This structure follows modern Python packaging best practices using:
- **src layout** for better testing isolation
- **pixi** for environment management
- **GitHub** for hosting and CI/CD
- **MkDocs Material** for documentation
- **PyPI** for package distribution

## Complete Directory Structure

```
MyPythonLib/
├── .github/
│   └── workflows/
│       └── docs.yml                    # GitHub Actions for documentation deployment
├── src/
│   └── mypythonlib/                    # Main Python package (src layout)
│       ├── __init__.py                 # Package initialization with version
│       └── README.md                   # Package-specific documentation
├── scripts/                            # CLI tools and entry points
│   ├── __init__.py                     # Scripts package initialization
│   ├── cli.py                          # Main CLI implementation
│   └── README.md                       # CLI documentation
├── tests/                              # Test suite
│   ├── __init__.py                     # Test package initialization
│   └── README.md                       # Testing guidelines
├── docs/                               # Documentation source
│   └── index.md                        # Main documentation page
├── context/                            # AI assistant resources
│   ├── hints/                          # Programming tutorials and guides
│   │   └── README.md                   # Hints directory documentation
│   ├── summaries/                      # Project experience summaries
│   │   └── README.md                   # Summaries directory documentation
│   ├── tasks/                          # Task definitions from humans
│   │   └── README.md                   # Tasks directory documentation
│   ├── logs/                           # Operational logs for AI memory
│   │   └── README.md                   # Logs directory documentation
│   ├── refcode/                        # Reference code repositories (git submodules)
│   │   └── README.md                   # Reference code documentation
│   ├── tools/                          # AI-created helper scripts
│   │   └── README.md                   # Tools directory documentation
│   └── README.md                       # Context directory overview
├── tmp/                                # Temporary files (not in git)
├── .gitignore                          # Git ignore patterns
├── .htmltest.yml                       # Link checking configuration (optional)
├── LICENSE                             # MIT License
├── README.md                           # Main project documentation
├── CLAUDE.md                           # AI assistant guidance
├── mkdocs.yml                          # Documentation configuration
├── pixi.toml                           # Environment and task management
├── pixi.lock                           # Locked dependencies (auto-generated)
└── pyproject.toml                      # Python packaging configuration
```

## Step-by-Step Creation Guide

### 1. Initialize Repository Structure

```bash
# Create main project directory
mkdir MyPythonLib
cd MyPythonLib

# Create all directories
mkdir -p .github/workflows
mkdir -p src/mypythonlib
mkdir -p scripts
mkdir -p tests
mkdir -p docs
mkdir -p context/{hints,summaries,tasks,logs,refcode,tools}
mkdir -p tmp

# Initialize git repository
git init -b main
```

### 2. Core Configuration Files

#### 2.1 pyproject.toml (Python Packaging)

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "mypythonlib"
version = "0.1.0"
description = "A modern Python library with professional development practices"
readme = "README.md"
requires-python = ">=3.8"
license = {text = "MIT"}
authors = [
    {name = "Your Name", email = "your.email@example.com"},
]
maintainers = [
    {name = "Your Name", email = "your.email@example.com"},
]
keywords = ["python", "library", "package"]
classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "Topic :: Software Development :: Libraries :: Python Modules",
    "License :: OSI Approved :: MIT License",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.8",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
]

dependencies = [
    # Add your runtime dependencies here
    # "requests>=2.28.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0.0",
    "pytest-cov>=4.0.0",
    "black>=22.0.0",
    "ruff>=0.1.0",
    "mypy>=1.0.0",
    "pre-commit>=3.0.0",
]

docs = [
    "mkdocs>=1.5.0",
    "mkdocs-material>=9.0.0",
]

[project.urls]
Homepage = "https://github.com/yourusername/MyPythonLib"
Documentation = "https://yourusername.github.io/MyPythonLib/"
Repository = "https://github.com/yourusername/MyPythonLib.git"
"Bug Tracker" = "https://github.com/yourusername/MyPythonLib/issues"

[project.scripts]
mypythonlib = "scripts.cli:main"

[tool.setuptools.packages.find]
where = ["src"]
include = ["mypythonlib*"]
exclude = ["tests*", "docs*", "context*"]

[tool.setuptools.package-dir]
"" = "src"

[tool.black]
line-length = 88
target-version = ['py38']
include = '\.pyi?$'

[tool.ruff]
line-length = 88
select = [
    "E",  # pycodestyle errors
    "W",  # pycodestyle warnings
    "F",  # pyflakes
    "I",  # isort
    "B",  # flake8-bugbear
    "C4", # flake8-comprehensions
    "UP", # pyupgrade
]
ignore = []
target-version = "py38"

[tool.mypy]
python_version = "3.8"
warn_return_any = true
warn_unused_configs = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py", "*_test.py"]
addopts = "-ra -q --strict-markers"

[tool.coverage.run]
branch = true
source = ["src/mypythonlib", "scripts"]

[tool.coverage.report]
exclude_lines = [
    "pragma: no cover",
    "def __repr__",
    "if self.debug:",
    "if __name__ == .__main__.:",
    "raise NotImplementedError",
    "pass",
    "except ImportError:",
]
```

#### 2.2 pixi.toml (Environment Management)

```toml
[project]
name = "mypythonlib"
version = "0.1.0"
description = "A modern Python library with professional development practices"
authors = ["Your Name <your.email@example.com>"]
channels = ["conda-forge"]
platforms = ["linux-64", "osx-64", "osx-arm64", "win-64"]

[tasks]
# Development tasks
test = "pytest tests/"
test-cov = "pytest --cov=src/mypythonlib --cov=scripts tests/"
lint = "ruff check src/ scripts/ tests/"
format = "black src/ scripts/ tests/"
typecheck = "mypy src/mypythonlib scripts"
dev = "pip install -e ."

# Build tasks
build = "python -m build"
clean = "rm -rf build dist *.egg-info"

# Documentation tasks
docs = "mkdocs build"
docs-serve = "mkdocs serve"
docs-deploy = "mkdocs gh-deploy --force"

[dependencies]
python = ">=3.8,<3.13"
pip = "*"
setuptools = ">=61.0"
wheel = "*"

# Development dependencies
pytest = ">=7.0.0"
pytest-cov = ">=4.0.0"
black = ">=22.0.0"
ruff = ">=0.1.0"
mypy = ">=1.0.0"
pre-commit = ">=3.0.0"

# Documentation dependencies
mkdocs = ">=1.5.0"
mkdocs-material = ">=9.0.0"

[feature.dev.dependencies]
ipython = "*"
jupyter = "*"

[environments]
dev = ["dev"]
```

#### 2.3 mkdocs.yml (Documentation Configuration)

```yaml
site_name: MyPythonLib
site_description: A modern Python library with professional development practices
site_author: Your Name
site_url: https://yourusername.github.io/MyPythonLib/

repo_name: yourusername/MyPythonLib
repo_url: https://github.com/yourusername/MyPythonLib
edit_uri: edit/main/docs/

theme:
  name: material
  palette:
    # Palette toggle for light mode
    - media: "(prefers-color-scheme: light)"
      scheme: default
      primary: blue
      accent: blue
      toggle:
        icon: material/brightness-7
        name: Switch to dark mode

    # Palette toggle for dark mode
    - media: "(prefers-color-scheme: dark)"
      scheme: slate
      primary: blue
      accent: blue
      toggle:
        icon: material/brightness-4
        name: Switch to light mode

  features:
    - content.code.copy
    - navigation.footer
    - navigation.instant
    - navigation.top
    - search.highlight
    - search.suggest

  icon:
    repo: fontawesome/brands/github

# Simple navigation
nav:
  - Home: index.md

# Basic extensions
markdown_extensions:
  - toc:
      permalink: true
  - tables
  - pymdownx.highlight
  - pymdownx.superfences

# Plugins
plugins:
  - search

# Additional configuration
extra:
  social:
    - icon: fontawesome/brands/github
      link: https://github.com/yourusername/MyPythonLib
      name: GitHub Repository

# Copyright
copyright: Copyright &copy; 2024 Your Name
```

### 3. Essential Python Files

#### 3.1 src/mypythonlib/__init__.py

```python
"""
MyPythonLib

A modern Python library with professional development practices.
"""

__version__ = "0.1.0"
__author__ = "Your Name"

# Future imports will be added here as modules are developed
# from .core import MyClass
# from .utils import utility_function
```

#### 3.2 scripts/cli.py

```python
"""
Command-line interface for MyPythonLib.
"""

import sys
import argparse


def main():
    """Main entry point for the mypythonlib CLI."""
    parser = argparse.ArgumentParser(
        description="MyPythonLib command-line interface",
        prog="mypythonlib"
    )
    
    parser.add_argument(
        "--version",
        action="version",
        version="%(prog)s 0.1.0"
    )
    
    # Add your CLI commands here
    parser.add_argument(
        "--example",
        help="Example command"
    )
    
    args = parser.parse_args()
    
    # Implement your CLI logic here
    print("MyPythonLib CLI - Add your functionality here")
    
    return 0


if __name__ == "__main__":
    sys.exit(main())
```

### 4. Documentation Files

#### 4.1 docs/index.md

```markdown
# MyPythonLib

A modern Python library with professional development practices.

## Overview

MyPythonLib provides [describe your library's purpose and main features].

## Installation

### From PyPI (Coming Soon)

```bash
pip install mypythonlib
```

### From Source

```bash
git clone https://github.com/yourusername/MyPythonLib.git
cd MyPythonLib
pip install -e .
```

## Quick Start

```python
import mypythonlib

# Add usage examples here
```

## Features

- **Feature 1**: Description of key feature
- **Feature 2**: Description of another feature
- **CLI Tools**: Command-line interface for quick operations
- **Extensible**: Easy to extend and customize

## Development

This project uses [pixi](https://pixi.sh) for environment management:

```bash
# Install pixi (if not already installed)
curl -fsSL https://pixi.sh/install.sh | bash

# Create development environment
pixi install

# Run tests
pixi run test
```

## Project Structure

```
MyPythonLib/
├── src/
│   └── mypythonlib/    # Main Python package
├── scripts/            # CLI tools
├── tests/             # Test suite
├── docs/              # Documentation
└── context/           # AI assistant resources
```

## Contributing

Contributions are welcome! Please read our contributing guidelines and submit pull requests to our repository.

## License

[MIT License](LICENSE)

## Links

- **GitHub**: [yourusername/MyPythonLib](https://github.com/yourusername/MyPythonLib)
- **Issues**: [Report bugs and request features](https://github.com/yourusername/MyPythonLib/issues)
- **Discussions**: [Community support](https://github.com/yourusername/MyPythonLib/discussions)
```

#### 4.2 README.md (Main Project)

Create a comprehensive README.md following the same structure as docs/index.md but with additional development information.

### 5. GitHub Actions

#### 5.1 .github/workflows/docs.yml

```yaml
name: Deploy Documentation

on:
  push:
    branches:
      - main
    paths:
      - 'docs/**'
      - 'mkdocs.yml'
      - '.github/workflows/docs.yml'

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          pip install mkdocs mkdocs-material

      - name: Build documentation
        run: mkdocs build --clean

      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: ./site

      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### 6. Git Configuration

#### 6.1 .gitignore

```gitignore
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# OS
.DS_Store
Thumbs.db

# Pixi
.pixi/

# Documentation build
site/

# Project specific
tmp/
```

### 7. AI Assistant Configuration

#### 7.1 CLAUDE.md

```markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MyPythonLib is a modern Python library designed with professional development practices including:
- Src layout for better testing isolation
- Pixi for environment management
- MkDocs Material for documentation
- GitHub Actions for CI/CD
- PyPI distribution ready

## Project Structure

```
MyPythonLib/
├── src/
│   └── mypythonlib/    # Main Python package (src layout)
├── scripts/            # CLI tools
├── tests/              # Test suite
├── docs/               # Documentation
├── context/            # AI assistant resources
└── pyproject.toml      # Python packaging configuration
```

## Development Environment

- Python environment is managed by **pixi** (see pixi.toml)
- Development commands:
  - `pixi run test` - Run tests
  - `pixi run lint` - Run linting
  - `pixi run format` - Format code
  - `pixi run build` - Build package

## Documentation

- **Documentation Site**: https://yourusername.github.io/MyPythonLib/
- **Local Development**: `pixi run docs-serve` - Serve docs locally
- **Building**: `pixi run docs` - Build static documentation
- **Deployment**: Automatic via GitHub Actions on main branch updates

## Architecture Overview

1. **Main Package** (`src/mypythonlib/`): Core library functionality using src layout
2. **CLI Tools** (`scripts/`): Command-line interface implementation
3. **Testing** (`tests/`): Comprehensive test suite
4. **Documentation** (`docs/`): MkDocs Material documentation

## Important Notes

- Uses src layout following modern Python packaging best practices
- Configured for PyPI publishing
- Documentation automatically deploys to GitHub Pages
- Development tools (linting, testing, formatting) are configured

## Development Conventions

- `tmp/` dir is for everything not intended to be uploaded to git
- Follow semantic versioning for releases
- All code should be tested and documented
```

### 8. License File

#### 8.1 LICENSE

```
MIT License

Copyright (c) 2024 Your Name

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```

## Complete Setup Commands

```bash
# 1. Create and navigate to project directory
mkdir MyPythonLib && cd MyPythonLib

# 2. Initialize git
git init -b main

# 3. Create directory structure
mkdir -p .github/workflows src/mypythonlib scripts tests docs context/{hints,summaries,tasks,logs,refcode,tools} tmp

# 4. Create all configuration files (copy content from above sections)
# - pyproject.toml
# - pixi.toml  
# - mkdocs.yml
# - .gitignore
# - LICENSE
# - README.md
# - CLAUDE.md
# - .github/workflows/docs.yml

# 5. Create Python package files
# - src/mypythonlib/__init__.py
# - scripts/__init__.py
# - scripts/cli.py
# - tests/__init__.py
# - docs/index.md

# 6. Create README.md files for each directory in context/

# 7. Initialize pixi environment
pixi install

# 8. Initial git commit
git add .
git commit -m "Initial project setup with modern Python structure"

# 9. Create GitHub repository and push
gh repo create MyPythonLib --public --source=.
git push -u origin main

# 10. Enable GitHub Pages (manually in repository settings)
# Go to Settings → Pages → Source: GitHub Actions
```

## Key Benefits of This Structure

1. **Modern Python Packaging**: Uses src layout and pyproject.toml
2. **Professional Development**: Configured linting, testing, and formatting
3. **Documentation**: Auto-deploying documentation with MkDocs Material
4. **Environment Management**: Pixi for reproducible development environments
5. **CI/CD Ready**: GitHub Actions for automation
6. **PyPI Ready**: Configured for easy package publishing
7. **AI Assistant Friendly**: Context directory and CLAUDE.md for AI collaboration

This structure provides a solid foundation for any Python library project with modern best practices and professional development workflows.