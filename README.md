# Codebase Genius

An AI-powered tool for automated code repository analysis, summary generation, and structure visualization.

## Overview

Codebase Genius helps developers quickly understand unfamiliar codebases by:

1. **Automated Repository Cloning**: Easily clone and analyze GitHub repositories
2. **Smart Code Summarization**: Generate concise, accurate summaries of codebases using Google's Gemini 2.5 Flash LLM
3. **Intelligent Structure Visualization**: Filter and display the relevant code structure, ignoring non-essential files
4. **Focused Documentation**: Identify and highlight key components of a project's architecture

## Features

- **Repository Analysis**: Clone and analyze repositories to understand their structure
- **README Summarization**: Generate concise summaries of project documentation
- **Intelligent Filtering**: Automatically filter out irrelevant files (build artifacts, cache files, etc.)
- **Recursive Structure Mapping**: Create detailed maps of project hierarchies
- **LLM-Powered Insights**: Leverage Google's Gemini 2.5 Flash for intelligent analysis

## Installation

### Prerequisites

- Python 3.8+
- Jac language environment

### Setup

1. Clone this repository:
   ```bash
   git clone https://github.com/SahanUday/Codebase-Genius.git
   cd Codebase-Genius
   ```

2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

3. Set up your Google API key for Gemini access (get a key from [Google AI Studio](https://makersuite.google.com/))
   ```bash
   # For Windows
   set GOOGLE_API_KEY=your_api_key_here
   
   # For Linux/Mac
   export GOOGLE_API_KEY=your_api_key_here
   ```

## Usage

Run the main script with:

```bash
jac run main.jac
```

By default, this will:
1. Clone the repository specified in the entry section
2. Generate a summary of the README
3. Analyze and display the folder structure

### Customizing Repository Analysis

To analyze a different repository, modify the `entry` section in `main.jac`:

```jac
with entry {
    repo = init_repo();
    root ++> repo;
    get_folder_structure(
        repo_url = 'https://github.com/username/repository.git',
        repo_dir = 'path/to/local/directory'
    ) spawn root;
    print("Summary:", repo.summary);
    print("Folder Structure:", repo.folder_structure);
}
```

## Project Structure

- `main.jac`: Core implementation with repository cloning, summarization, and structure analysis
- `repo_clone.jac`: Utility functions for repository cloning
- `filestructure.jac`: Functions for analyzing and organizing file structures
- `requirements.txt`: Project dependencies

## Technical Implementation

Codebase Genius uses:
- **Jac Language**: For agent-oriented programming
- **GitPython**: For Git repository operations
- **Google Gemini 2.5 Flash**: For natural language processing and summarization
- **Recursive Tree Traversal**: For analyzing repository hierarchies

## Future Enhancements

- **Dependency Analysis**: Automatically identify and map project dependencies.
- **Architectural Pattern Detection**: Detect common architectural patterns within codebases.
- **Method Extraction**: Extract and summarize key code methods and functions.
- **Comprehensive Explanation**: Provide detailed explanations of code components and their interactions.
- **Interactive Visualization**: Enable interactive exploration of code structure and relationships.
- **Web-Based Execution**: Offer a web interface for running analyses and viewing results.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
