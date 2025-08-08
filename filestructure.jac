import os;
import pathspec;
import json;
import from typing { Dict, Any, List, Tuple }
import from mtllm.llm { Model }

# Connect to Gemini
glob llm = Model(model_name="gemini-2.5-flash", verbose=False);


"""Load .gitignore for a specific directory."""
def load_gitignore_for_dir(local_dir: str) -> pathspec.PathSpec {
    gitignore_path = os.path.join(local_dir, '.gitignore');
    if os.path.exists(gitignore_path) {
        with open(gitignore_path, 'r') as f  {
            return pathspec.PathSpec.from_lines('gitwildmatch', f);
        }
    }
    return pathspec.PathSpec.from_lines('gitwildmatch', []);
}


"""Get top-level directories and files, respecting .gitignore."""
def get_first_layer(root_dir: str) -> Tuple[ List[ str ], List[ str ] ] {
    dir_spec = load_gitignore_for_dir(root_dir);
    (dirnames, filenames) = ([], []);
    with os.scandir(root_dir) as entries  {

            for
            <>entry
            in
            entries
            {
            if (<>entry.is_dir() and not dir_spec.match_file((<>entry.name + '/')) ) {
                dirnames.append(<>entry.name);
            } elif (<>entry.is_file() and not dir_spec.match_file(<>entry.name) ) {
                filenames.append(<>entry.name);
            }
            }
    }
    return (sorted(dirnames), sorted(filenames));
}


"""Print items in a tree-like structure."""
def print_tree(items: List[ str ], prefix: str = '', is_file: bool = False) -> None {
    for (i, item) in enumerate(items) {
        connector = '└── ' if (i == (len(items) - 1)) else '├── ';
        print(f"{prefix}{connector}{item}{'/' if not is_file else ''}");
    }
}


"""Prompt user to select items (files or folders) from a list."""
def get_user_input(items: List[ str ], item_type: str) -> List[ str ] {
    if not items { print(f"'No '{item_type}'s available to select.'"); return [];  }
    print(f"'\nAvailable '{item_type}'s:'");
    print_tree(items, is_file=(item_type == 'file'));
    selected =
        input(f"Enter {item_type} names (comma-separated, or 'none' for none): ").strip();

        if
        (selected.lower() == 'none')
        {
        return [];
        }
    selected_items = [ item.strip() for item in selected.split(',') ];
    valid_items = [ item for item in selected_items if (item in items) ];
    if not valid_items { print(f"'No valid '{item_type}'s selected. Proceeding with none.'"); return [];  }
    if (len(valid_items) < len(selected_items)) {
        invalid = (<>set(selected_items) - <>set(valid_items));
        print(f"'Warning: Ignoring invalid '{item_type}'s: '{', '.join(invalid)}");
    }
    return valid_items;
}


"""Build a nested dictionary for the specified folders' complete structure."""
def build_folder_tree(local_dir: str, folders: List[ str ]) -> Dict[ str, Any ] {
    tree = {'folders' : {} , 'files' : [] };
    root_spec = load_gitignore_for_dir(local_dir);
    for folder in folders {
        folder_path = os.path.join(local_dir, folder);
        current =
            tree[ 'folders' ].setdefault(folder, {'folders' : {} , 'files' : [] });
        for (dirpath, dirnames, filenames) in os.walk(folder_path) {
            rel_dir = os.path.relpath(dirpath, local_dir);
            dir_spec = (load_gitignore_for_dir(dirpath) or root_spec );
            dirnames[ : ] =
                [ d for d in dirnames if not dir_spec.match_file((os.path.join(rel_dir, d) + '/')) ];
            sub_current = current;
            for filename in sorted(filenames) {
                rel_path =
                    os.path.join(rel_dir, filename) if (rel_dir != '.') else filename;
            if not dir_spec.match_file(rel_path) {
                sub_current[ 'files' ].append(filename);
            } }
        if (rel_dir != folder) { parts = rel_dir.split(os.sep)[ 1 : ]; } }
    }
    return tree;
}


"""Save the repository tree to a JSON file."""
def save_repo_tree_to_json(tree: Dict[ (str, Any) ], output_file: str) -> None {
    with open(output_file, 'w', encoding='utf-8') as f  {
        json.dump(tree, f, indent=4, sort_keys=True);
    }
}

"""\n    Reads a JSON file and sends its contents to an OpenAI LLM.\n    \n    Args:\n        file_path (str): Path to the JSON file (default: 'output_jason.json').\n        model (str): OpenAI model to use (default: 'gpt-3.5-turbo').\n    \n    Returns:\n        str: Response from the OpenAI LLM or an error message.\n    """
def read_json_and_query_gemini(
    file_path: Any = 'repo_tree.json',
    model: Any = 'gemini-2.5-flash'
) {
    genai.configure(api_key=os.getenv('GEMINI_API_KEY'));
    with open(file_path, 'r') as file  {
        json_data = json.load(file);
    }
    json_string = json.dumps(json_data, indent=2);
    prompt = f"' filter the above folder structure and remove unwanted useless files folders to project understand from the structure:\n\n'{json_string}";
    model = genai.GenerativeModel(model_name=model);
    response =
        model.generate_content(
            prompt,
            generation_config={'max_output_tokens' : 500 , 'temperature' : 0.7 }
        );
    return response.text.strip();
}


# """Read repo_tree.json and  filter the above folder structure remove unwanted useless files folders to project understand from the structure"""
# def process_repo_tree() -> str by llm();
    
#     with open('repo_tree.json', 'r') as file  {
#         repo_data = json.load(file);
#     }
#     # Convert JSON data to string for LLM processing
#     repo_str = json.dumps(repo_data, indent=2)
#     # Pass to LLM (assuming LLM accepts string input and returns string)
#     response = llm.process(repo_str)
#     return response
    


"""Main function to generate JSON tree based on user-selected files and folders."""
def main() {
    local_dir = 'D:\\MORASe\\Project\\Jac\\Jac-Forest-Fire';
    output_json = 'repo_tree.json';
    print(f"'Step 1: Top-level contents of '{local_dir}', respecting .gitignore'");
    (dirnames, filenames) = get_first_layer(local_dir);
    if dirnames {
        print('Directories:');
        print_tree(dirnames);
    }
    if filenames {
        print('Files:');
        print_tree(filenames, is_file=True);
    }
    print('\nStep 2: Select required files');
    selected_files = get_user_input(filenames, 'file');
    print('\nStep 3: Select required folders');
    selected_folders = get_user_input(dirnames, 'folder');
    print(f"'\nStep 4: Generating JSON tree structure in '{output_json}");
    tree = build_folder_tree(local_dir, selected_folders);
    tree[ 'files' ] = sorted(selected_files);
    save_repo_tree_to_json(tree, output_json);
    print(f"'JSON tree saved to '{output_json}");
    #result = read_json_and_query_gemini();
    #print(result);
    # result = process_repo_tree();
    # print(result);
}


with entry {
    if (__name__ == '__main__') {
        main();
    }
}

