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
    has chapter_number: int=0;
    has heading: str="";
    has transition_section_from_previous: str="";
    has highlevel_explanation_section: str="";
    has key_concepts_section: str="";
    has usecases_section: dict={"code_examples": [], "example_input": "","expected_output": "","description": ""};
    has internal_improvements_section: str="";
    has mermaid_diagram_section: list[str]=[];
    has ending_section: dict={"summary": "","transition_to_next_chapter": ""};
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


"""Obtain all_codes and identify new abstractions, minimum 5 or 6.
For each abstraction, include its name, a short description (under 200 words with an analogy), and a list of related_files."""
def extract_abstractions(all_codes: dict) -> list[Absts] by llm(method="Reason");

"""Obtain given project abstractions, code snippets and identify key relationships between the abstractions for understanding best order of abstractions to explain. 
Each relationship should show a from_abstraction, to_abstraction, and a brief label(A brief (a few words) description of the interaction)."""
def get_relationships(abstractions: list, code_snippets: dict) -> list[Rels] by llm(method="Reason");

"""Obtain given the project summary, abstractions, and their relationships,
Determine best order to explain this project in a tutorial.
Output the ordered list of abstraction indices"""
def chapter_ordering(summary: str, abstractions: list, relationships: list) -> list[int] by llm(method="Reason");

sem Cformat = "Cformat is a structured format for returning format of chapter_drafting function.";
sem Cformat.chapter_number = "The number of the chapter";
sem Cformat.heading = "Clear heading of the chapter for providing concept name";
sem Cformat.transition_section_from_previous = "If this is not the first chapter, begin with a brief transition from the previous chapter. If this is Chapter 1, provide an introduction.";
sem Cformat.highlevel_explanation_section = "Begin with a high-level motivation explaining what problem this abstraction solves and why it is important.";
sem Cformat.key_concepts_section = "break down into key concepts. Explain each concept one-by-one in a very beginner-friendly way.";
sem Cformat.usecases_section = "Explain how to use this abstraction to solve the use case. Also give example inputs and outputs for code snippets.";
sem Cformat.internal_improvements_section = " Describe the internal implementation to help understand what's under the hood.";
sem Cformat.mermaid_diagram_section = "Use mermaid diagrams to illustrate complex concepts (```mermaid``` format), each diagram as the element of list.";
sem Cformat.ending_section = "brief conclusion that summarizes what was learned and if has next chapter, provides a transition to the next chapter. if not, provide a closing statement.";

"""Obtain the abstractions list and complete codebase and output the list of drafted chapters according to the each abstraction, 
use the relevant codes for each abstraction from the codebase. Generate drafted chapters as the Cformat object."""
def chapter_drafting(abstractions_list: list[Absts], all_code_base: dict[str, str]) -> list[Cformat] by llm(method="Reason");

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