import os
import pathspec
import json
from typing import Dict, Any, List, Tuple

def load_gitignore_for_dir(dirpath: str) -> pathspec.PathSpec:
    """Load .gitignore for a specific directory."""
    gitignore_path = os.path.join(dirpath, '.gitignore')
    if os.path.exists(gitignore_path):
        with open(gitignore_path, 'r') as f:
            return pathspec.PathSpec.from_lines('gitwildmatch', f)
    return pathspec.PathSpec.from_lines('gitwildmatch', [])

def get_first_layer(root_dir: str) -> Tuple[List[str], List[str]]:
    """Get top-level directories and files, respecting .gitignore."""
    dir_spec = load_gitignore_for_dir(root_dir)
    dirnames, filenames = [], []

    with os.scandir(root_dir) as entries:
        for entry in entries:
            if entry.is_dir() and not dir_spec.match_file(entry.name + '/'):
                dirnames.append(entry.name)
            elif entry.is_file() and not dir_spec.match_file(entry.name):
                filenames.append(entry.name)

    return sorted(dirnames), sorted(filenames)

def print_tree(items: List[str], prefix: str = "", is_file: bool = False) -> None:
    """Print items in a tree-like structure."""
    for i, item in enumerate(items):
        connector = "└── " if i == len(items) - 1 else "├── "
        print(f"{prefix}{connector}{item}{'/' if not is_file else ''}")

def get_user_input(items: List[str], item_type: str) -> List[str]:
    """Prompt user to select items (files or folders) from a list."""
    if not items:
        print(f"No {item_type}s available to select.")
        return []

    print(f"\nAvailable {item_type}s:")
    print_tree(items, is_file=(item_type == "file"))
    selected = input(f"Enter {item_type} names (comma-separated, or 'none' for none): ").strip()

    if selected.lower() == 'none':
        return []

    selected_items = [item.strip() for item in selected.split(',')]
    valid_items = [item for item in selected_items if item in items]

    if not valid_items:
        print(f"No valid {item_type}s selected. Proceeding with none.")
        return []
    if len(valid_items) < len(selected_items):
        invalid = set(selected_items) - set(valid_items)
        print(f"Warning: Ignoring invalid {item_type}s: {', '.join(invalid)}")

    return valid_items

def build_folder_tree(root_dir: str, folders: List[str]) -> Dict[str, Any]:
    """Build a nested dictionary for the specified folders' complete structure."""
    tree = {"folders": {}, "files": []}
    root_spec = load_gitignore_for_dir(root_dir)

    for folder in folders:
        folder_path = os.path.join(root_dir, folder)
        current = tree["folders"].setdefault(folder, {"folders": {}, "files": []})

        for dirpath, dirnames, filenames in os.walk(folder_path):
            rel_dir = os.path.relpath(dirpath, root_dir)
            dir_spec = load_gitignore_for_dir(dirpath) or root_spec

            # Filter directories
            dirnames[:] = [
                d for d in dirnames
                if not dir_spec.match_file(os.path.join(rel_dir, d) + '/')
            ]

            # Navigate to the current node
            sub_current = current
            if rel_dir != folder:
                parts = rel_dir.split(os.sep)[1:]  # Skip the top-level folder name
                for part in parts:
                    sub_current = sub_current["folders"].setdefault(part, {"folders": {}, "files": []})

            # Add filtered files
            for filename in sorted(filenames):
                rel_path = os.path.join(rel_dir, filename) if rel_dir != '.' else filename
                if not dir_spec.match_file(rel_path):
                    sub_current["files"].append(filename)

    return tree

def save_repo_tree_to_json(tree: Dict[str, Any], output_file: str) -> None:
    """Save the repository tree to a JSON file."""
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(tree, f, indent=4, sort_keys=True)

def main():
    """Main function to generate JSON tree based on user-selected files and folders."""
    root_directory = '.'  # Change to specific path if needed
    output_json = 'repo_tree.json'

    # Step 1: Get and print first layer
    print(f"Step 1: Top-level contents of {root_directory}, respecting .gitignore")
    dirnames, filenames = get_first_layer(root_directory)
    
    if dirnames:
        print("Directories:")
        print_tree(dirnames)
    if filenames:
        print("Files:")
        print_tree(filenames, is_file=True)
    
    # Step 2: Get user-specified files
    print("\nStep 2: Select required files")
    selected_files = get_user_input(filenames, "file")

    # Step 3: Get user-specified folders
    print("\nStep 3: Select required folders")
    selected_folders = get_user_input(dirnames, "folder")

    # Step 4: Build and save JSON with selected files and folder structures
    print(f"\nStep 4: Generating JSON tree structure in {output_json}")
    tree = build_folder_tree(root_directory, selected_folders)
    tree["files"] = sorted(selected_files)  # Add only selected files at top level
    save_repo_tree_to_json(tree, output_json)
    print(f"JSON tree saved to {output_json}")

if __name__ == "__main__":
    main()