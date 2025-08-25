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

node documentation {
    has chapter_order: list = [];
    has drafted_chapters: list = [];
}

obj Cformat {
    has heading: str="";
    has transition_section_from_previous: str="";
    has highlevel_explanation_section: str="";
    has key_concepts_section: str="";
    has usecases_section: str="";
    has mermaid_diagram_section: str="";
    has ending_section: str="";
    has transition_section_to_next_chapter: str="";
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


"""Given a cloned GitHub repository path and a project summary, 
identify and filter out non-essential files. You can use get_top_level_structure_dict tool for obtaining the top layer of the file/folder structure and get_all_file_paths tool for getting all file paths in the repository. Also use summary for understanding the project context.
Return a list of only the meaningful source code files that are crucial for understanding the project's logic and abstractions. Exclude documentationumentation, configuration, test, and dependency files.""" 
def get_filtered_folder_structure(repo_path: str = '.', summary: str = '') -> list by llm(method="ReAct", tools=[get_top_level_structure_dict, get_all_file_paths]);

def read_files_from_list(file_paths: list[ str ]) -> dict();


"""Obtain all_codes and identify new abstractions atleast 5 or 6.Generate each abstractions as Absts objects."""
def extract_abstractions(all_codes: dict) -> list[Absts] by llm(method="Reason");

"""Obtain given project abstractions and identify key relationships between the abstractions for understanding best order of abstractions to explain. 
Each relationship should show a from_abstraction, to_abstraction, and a brief label(A brief (a few words) description of the interaction)."""
def get_relationships(abstractions: list) -> list[Rels] by llm(method="Reason");

"""Obtain given the project summary, all abstractions, and their all relationships,
Determine best order to explain this project in a tutorial.
Output the ordered list of abstraction indices"""
def chapter_ordering(summary: str, all_abstractions: list, all_relationships: list) -> list[int] by llm(method="Reason");

# """Obtain the abstractions list, codebase relevant code files, previous chapter and next chapter and output the drafted chapter according to the provided informations, 
# Generate drafted chapter as the Cformat object."""
# def chapter_drafting(abstractions_list: list, all_code_base: dict, previous_chapter: list, next_chapter: list) -> list[Cformat] by llm(method="Reason");

def get_relavent_codes(each_abstraction: Absts) -> dict {
    code_list = each_abstraction.related_files;
    codes = {key: code.code_base[key] for key in code_list};
    return all_codes;
}

sem Cformat = "Cformat is a structured format for drafted chapters.";
sem Cformat.heading = "Clear heading of the chapter for providing concept name";
sem Cformat.transition_section_from_previous = "If this is not the first chapter, begin with a brief transition from the previous chapter about under 50 words. If this is Chapter 1, provide an introduction about under 75 words.";
sem Cformat.highlevel_explanation_section = "Begin with a high-level motivation explaining what problem this abstraction solves and why it is important, about under 150 words.";
sem Cformat.key_concepts_section = "break down into key concepts. Explain each concept one-by-one in a very beginner-friendly way about under 100 words for each.";
sem Cformat.usecases_section = "Explain how to use this abstraction to solve the use case about under 200 words. Also give example inputs and outputs.";
sem Cformat.mermaid_diagram_section = "Use mermaid diagrams to illustrate complex concepts (```mermaid``` format).";
sem Cformat.ending_section = "brief conclusion that summarizes what was learned about under 100 words.";
sem Cformat.transition_section_to_next_chapter = "If this is not the last chapter, end with a brief transition to the next chapter about under 50 words. If this is the last chapter, provide a conclusion about under 100 words.";

"""Obtain the abstractions list and in abstractions_list, generate drafted chapters as Cformat objects for each abstraction (each_abstraction)
To get the relevant code snippets for each chapter (for each abstraction, each_abstraction= one element of the abstractions_list at once), use the get_relavent_codes function."""
def chapter_drafting(abstractions_list: list) -> list[Cformat] by llm(method="ReAct", tools=[get_relavent_codes]);

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
    
    can analyze with relationships entry;
}

walker DocGenerator(AnalyzeRelationships) {
    
    can ordering with documentation entry;
}

with entry {
    repo = init_repo();
    code = codebase();
    abst = abstracted();
    rel = relationships();
    doc = documentation();

    root ++> repo ++> code ++> abst ++> rel ++> doc;
    DocGenerator(repo_url = 'https://github.com/SahanUday/Airvix-App.git',repo_dir = 'E:\\GitHub_Repo\\Codebase-Genius\\AirVix-App') spawn root;
    # print("Summary:", repo.summary);
    # print("Folder Structure:", repo.folder_structure);
    # print("Codebase:", code.code_base);
    # print("Abstractions:");
    # print("Abstractions:", abst.abstractions);
    # print("Relationships:");
    # print("Relationships:", rel.relationships);
    # print("Chapter Order:", doc.chapter_order);
    print("Drafted Chapters:");
    print(doc.drafted_chapters);
}