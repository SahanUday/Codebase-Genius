#import from git { Repo }
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

node abstracted {
    has abstractions: list = [];
}

obj Absts {
    has name: str;
    has description: str;
    has related_files: list[str];
}

node relationships {
    has relationships: list = [];
}

obj Rels {
    has from_abstraction: str;
    has to_abstraction: str;
    has label: str;
}


def read_in_chunks(file_path: any, chunk_size: any = 150);

"""
obtain this chunk of text and summary of get so far and 
give the response as the new summary of the chunk of text 
combined with the given summary so far, maximum 150 lines.
"""
def send_to_gemini(text_chunk: str, summary: str) -> str by llm();

def get_top_level_structure_dict(repo_path: str) -> dict();

# """
# Using the repo_path and def get_top_level_structure_dict(repo_path: str) tool get the top layer of the file/folder structure of the project.
# After based on top layer file/folder structure and given summary of the project, remove unwanted useless files folders, remain only for understanding the project's abstractions, relationships and Identify and return only the **meaningful source code files** from this list.
# Give the dictionary of filtered out top layer of the  file/folder struture
# """
# def filter_toplayer_files_folders(repo_path: str, summary:str) -> dict by llm(method="ReAct", tools=[get_top_level_structure_dict]);

def get_all_file_paths(repo_path: str) -> list();


"""
Given a cloned GitHub repository path and a project summary, 
identify and filter out non-essential files. You can use get_top_level_structure_dict tool for obtaining the top layer of the file/folder structure and get_all_file_paths tool for getting all file paths in the repository. Also use summary for understanding the project context.
Return a list of only the meaningful source code files that are crucial for understanding the project's logic and abstractions. Exclude documentation, configuration, test, and dependency files.""" 
def get_filtered_folder_structure(repo_path: str = '.', summary: str = '') -> list by llm(method="ReAct", tools=[get_top_level_structure_dict, get_all_file_paths]);

def read_files_from_list(file_paths: list[ str ]) -> dict();


"""Obtain all_codes and identify new abstractions, minimum 5 or 6.
For each abstraction, include its name, a short description (under 200 words with an analogy), and a list of related_files.
"""
def extract_abstractions(all_codes: dict) -> list[Absts] by llm(method="Reason");

"""
Obtain given project abstractions, code snippets and identify key relationships between the abstractions for understanding best order of abstractions to explain. 
Each relationship should show a from_abstraction, to_abstraction, and a brief label(A brief (a few words) description of the interaction).
"""
def get_relationships(abstractions: list, code_snippets: dict) -> list[Rels] by llm(method="Reason");

walker main {
    has repo_url: str;
    has repo_dir: str;

    can repo_clone with `root entry; 
    can get_summ with init_repo entry;
}

walker get_folder_structure(main) {

    can access with init_repo entry;
}

walker get_codebase(get_folder_structure) {

    can get_c with codebase entry;
}

walker IdentifyAbstractions(get_codebase) {

    can identify with abstracted entry;
}

walker AnalyzeRelationships(IdentifyAbstractions) {
    
    can analyze with relationships entry {

    }
}

with entry {
    repo = init_repo();
    code = codebase();
    abst = abstracted();
    rel = relationships();
    root ++> repo ++> code ++> abst ++> rel ;
    AnalyzeRelationships(repo_url = 'https://github.com/SahanUday/Airvix-App.git',repo_dir = 'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App') spawn root;
    # print("Summary:", repo.summary);
    # print("Folder Structure:", repo.folder_structure);
    #print("Codebase:", code.code_base);
    print("Abstractions:");
    print("Abstractions:", abst.abstractions);
    print("Relationships:");
    print("Relationships:", rel.relationships);
}