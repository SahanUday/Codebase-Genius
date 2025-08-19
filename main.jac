import from git { Repo }
import from pathlib { Path }
import from mtllm.llms { Gemini }
import os;

glob llm = Gemini(model_name="gemini-2.5-flash");

node init_repo {
    has folder_structure: list[str] = [];
    has summary: str = "";
}

node codebase {
    has code_base: dict = {};
}

node abstractions {
    has abstractions: dict = {};
}

node relationships {
    has relationships: list[dict] = [];
}



def read_in_chunks(file_path: any, chunk_size: any = 150) {
    with open(file_path, 'r', encoding='utf-8') as f  { chunk = []; for (line_num, line) in enumerate(f, 1) { chunk.append(line); if ((line_num % chunk_size) == 0) {
        yield ''.join(chunk) ;;
        chunk = [];
    } }  if chunk {
        yield ''.join(chunk) ;;
    } }
}

"""
obtain this chunk of text and summary of get so far and 
give the response as the new summary of the chunk of text 
combined with the given summary so far, maximum 150 lines.
"""
def send_to_gemini(text_chunk: str, summary: str) -> str by llm();

def get_top_level_structure_dict(repo_path: str) -> dict {
    repo_path = Path(repo_path).resolve();
    structure = {'folders' : [] , 'files' : [] };
    for item in sorted(repo_path.iterdir()) { if item.is_dir() {
        structure[ 'folders' ].append((item.name));
    } else {
        structure[ 'files' ].append(item.name);
    }  }
    return structure;
}

# """
# Using the repo_path and def get_top_level_structure_dict(repo_path: str) tool get the top layer of the file/folder structure of the project.
# After based on top layer file/folder structure and given summary of the project, remove unwanted useless files folders, remain only for understanding the project's abstractions, relationships and Identify and return only the **meaningful source code files** from this list.
# Give the dictionary of filtered out top layer of the  file/folder struture
# """
# def filter_toplayer_files_folders(repo_path: str, summary:str) -> dict by llm(method="ReAct", tools=[get_top_level_structure_dict]);

def get_all_file_paths(repo_path: str) -> list {
    repo_path = Path(repo_path);
    all_files = [];
    if (repo_path.exists() and repo_path.is_dir() ) {
        for file_path in repo_path.rglob('*') { 
            if file_path.is_file() {
                all_files.append(str(file_path.resolve()));
            }
        }
    }
    return all_files;
}
"""
Given a cloned GitHub repository path and a project summary, 
identify and filter out non-essential files. You can use get_top_level_structure_dict tool for obtaining the top layer of the file/folder structure and get_all_file_paths tool for getting all file paths in the repository. Also use summary for understanding the project context.
Return a list of only the meaningful source code files that are crucial for understanding the project's logic and abstractions. Exclude documentation, configuration, test, and dependency files.""" 
def get_filtered_folder_structure(repo_path: str = '.', summary: str = '') -> list by llm(method="ReAct", tools=[get_top_level_structure_dict, get_all_file_paths]);

def read_files_from_list(file_paths: list[ str ]) -> dict {
    files_dict = {};
    total_files = len(file_paths);
    processed_files = 0;
    for filepath in file_paths { 
        relpath = os.path.basename(filepath); 
        status ='processed'; 
        with open(filepath, 'r', encoding='utf-8-sig') as f  { 
            content = f.read(); 
        } 
        files_dict[ relpath ] = [content];  
        processed_files += 1; 
        if (total_files > 0) {
            percentage = ((processed_files / total_files) * 100);
            rounded_percentage = int(percentage);
            print(f"Progress: {processed_files}/{total_files} ({rounded_percentage}%) {relpath} [{status}]");
        }
    }

    print(f"'\nFound '{len(files_dict)}' readable files:'");
    for path in files_dict { print(f"'  '{path}"); }
    return files_dict;
}

"""
Obtain all_codes and identify new abstractions, minimum 5 or 6.
For each abstraction, include its name, a short description (under 50 words with an analogy), and a list of related_files.
The final output must be contain name, description, and related_files.
output response dictionary format is {
    {"name": "Abstraction Name",
    "description": "Short description of the abstraction.",
    "related_files": ["file1.py", "file2.py"]}
}
"""
def extract_abstractions(all_codes: dict) -> dict by llm();

# def get_relationships(relation: dict, code_snippets: dict) -> dict by llm();

walker main {
    has repo_url: str;
    has repo_dir: str;

    can repo_clone with `root entry {
        print("Cloning repository...");
        #Repo.clone_from(self.repo_url, self.repo_dir);
        print('Repository cloned successfully!');
        visit[-->];
    }

    can get_summ with init_repo entry {

        file_path = 'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App\\README.md';
        for (i, chunk_text) in enumerate(read_in_chunks(file_path, 200), 1) { 
            print("Getting summary...");
            response = send_to_gemini(chunk_text, here.summary);
            here.summary = response;
        }
    }
}

walker get_folder_structure(main) {

    can access with init_repo entry {
        top_layer: dict ={};
        print("Accessing folder structure...");
        repo_path = Path('E:\GitHub_Repo\Codebase-Genius\AirVix-App');
        # top_layer = filter_toplayer_files_folders(repo_path,here.summary);
        # print(top_layer);
        here.folder_structure = get_filtered_folder_structure(repo_path,here.summary);
        visit[-->];
    }

}

walker get_codebase(get_folder_structure) {
    can get_c with codebase entry {
        print("Accessing codebase...");
        here.code_base = read_files_from_list(repo.folder_structure);
        print("Codebase accessed successfully!");
        visit[-->];
    }
}

walker IdentifyAbstractions(get_codebase) {
    can identify with abstractions entry {
        # for (file_name,file_content) in code.code_base.items() {
        #     print("Identifying abstractions...");
        #     updated_abstractions = extract_abstractions(file_content, file_name,here.abstractions);
        #     here.abstractions = updated_abstractions;
        #     print(here.abstractions);
        # }
        updated_abstractions = extract_abstractions(code.code_base);
        here.abstractions = updated_abstractions;
        print(here.abstractions);

        print("Abstractions identified successfully!");
    }
}

walker AnalyzeRelationships(IdentifyAbstractions) {
    can analyze with relationships entry {

    }
}

with entry {
    repo = init_repo();
    code = codebase();
    abst = abstractions();
    rel = relationships();
    root ++> repo ++> code ++> abst ++> rel ;
    IdentifyAbstractions(repo_url = 'https://github.com/SahanUday/Airvix-App.git',repo_dir = 'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App') spawn root;
    # print("Summary:", repo.summary);
    # print("Folder Structure:", repo.folder_structure);
    #print("Codebase:", code.code_base);
    print("Abstractions:", abst.abstractions);
}