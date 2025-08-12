import from git { Repo }
import from pathlib { Path }
import from mtllm.llms { Gemini }

glob llm = Gemini(model_name="gemini-2.5-flash");

node init_repo {
    has folder_structure: dict = {};
    has summary: str = "";
}

def read_in_chunks(file_path: any, chunk_size: any = 150) {
    with open(file_path, 'r', encoding='utf-8') as f  { chunk = []; for (line_num, line) in enumerate(f, 1) { chunk.append(line); if ((line_num % chunk_size) == 0) {
        yield ''.join(chunk) ;;
        chunk = [];
    } }  if chunk {
        yield ''.join(chunk) ;;
    } }
}

"""obtain this chunk of text and summary of get so far and give the response as the new summary of the chunk of text combined with the given summary so far.
"""
def send_to_gemini(text_chunk: str, summary: str) -> str by llm();

def get_top_level_structure_dict(repo_path: str = '.') {
    repo_path = Path(repo_path).resolve();
    structure = {'folders' : [] , 'files' : [] };
    for item in sorted(repo_path.iterdir()) { if item.is_dir() {
        structure[ 'folders' ].append((item.name));
    } else {
        structure[ 'files' ].append(item.name);
    }  }
    return structure;
}

"""You are given a repository path of a project.
Use the provided function get_top_level_structure_dict(repo_path) to get the top-level file and folder structure of the project.
From the resulting structure, filter out any unwanted, useless, or non-essential files and folders that are not relevant for understanding the programming or code structure of the project (e.g., .git, node_modules, build artifacts, temporary files, test cache, documentation images, logs, etc.).
Return the cleaned/filtered structure in the format:
{
    "folders": [],
    "files": []
}
Make sure the result preserves only the meaningful source code and configuration directories/files that help in understanding the project’s programming logic.
"""
def get_filtered_folder_structure(repo_path: str = '.') -> dict by llm(method="ReAct", tools=[get_top_level_structure_dict]);

def get_full_structure(repo_path: any, specific_folders: any) {
    results = {'folders' : {} , 'files' : [] };
    for folder in specific_folders { 
        folder_path = (repo_path / folder); 
        items ={'folders' : {} , 'files' : [] }; 
        if (folder_path.exists() and folder_path.is_dir() ) {
            for item in sorted(folder_path.iterdir()) {
                if item.is_dir() {
                    items[ 'folders' ][ item.name ] = get_full_structure(folder_path, [item.name])[ 'folders' ][ item.name ];
                } else {
                    items[ 'files' ].append(item.name);
                }
            }
        }
    results[ 'folders' ][ folder ] = items;
    }
    return results;
}

walker main {
    has repo_url: str;
    has repo_dir: str;

    can repo_clone with `root entry {
        print("Cloning repository...");
        Repo.clone_from(self.repo_url, self.repo_dir);
        print('Repository cloned successfully!');
        visit[-->];
    }

    can get_summ with init_repo entry {
        print("Getting summary...");

        file_path = 'E:\\GitHub_Repo\\Codebase-Genius\\Jac-Forest-Fire\\README.md';
        for (i, chunk_text) in enumerate(read_in_chunks(file_path, 50), 1) { 
            response = send_to_gemini(chunk_text, here.summary);
            here.summary = response;
        }
    }
}

walker get_folder_structure(main) {
    can access with init_repo entry {
        print("Accessing folder structure...");
            
        repo_path = Path('E:\GitHub_Repo\Codebase-Genius\Jac-Forest-Fire');
        filtered_structure = get_filtered_folder_structure(repo_path);

        specific_files = filtered_structure["files"];
        here.folder_structure["folders"] = get_full_structure(repo_path, filtered_structure["folders"])["folders"];
        here.folder_structure["files"] = specific_files;
    }
}

with entry {
    repo = init_repo();
    root ++> repo;
    get_folder_structure(repo_url = 'https://github.com/SahanUday/Airvix-App.git',repo_dir = 'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App') spawn root;
    print("Summary:", repo.summary);
    print("Folder Structure:", repo.folder_structure);
}